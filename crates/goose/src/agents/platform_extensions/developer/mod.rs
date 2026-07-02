pub mod edit;
pub mod image;
pub mod shell;
pub mod tree;

use crate::agents::extension::PlatformExtensionContext;
use crate::agents::mcp_client::{Error, McpClientTrait};
use crate::agents::ToolCallContext;
use anyhow::Result;
use async_trait::async_trait;
use edit::{EditTools, FileEditParams, FileWriteParams};
use image::{ImageReadParams, ImageTool};
use indoc::indoc;
use rmcp::model::{
    CallToolResult, Content, Implementation, InitializeResult, JsonObject, ListToolsResult,
    ServerCapabilities, Tool, ToolAnnotations,
};
use schemars::{schema_for, JsonSchema};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use shell::{shell_display_name, ShellOutput, ShellParams, ShellTool};
use std::collections::HashMap;
use std::sync::Arc;
use tokio_util::sync::CancellationToken;
use tree::{TreeParams, TreeTool};

pub static EXTENSION_NAME: &str = "developer";

pub struct DeveloperClient {
    info: InitializeResult,
    shell_tool: Arc<ShellTool>,
    edit_tools: Arc<EditTools>,
    tree_tool: Arc<TreeTool>,
    image_tool: Arc<ImageTool>,
    // Per-session volatile key-value storage, intentionally RAM-only.
    session_kv_store: Arc<std::sync::RwLock<HashMap<String, HashMap<String, String>>>>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct KvSetParams {
    pub key: String,
    pub value: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct KvGetParams {
    pub key: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct KvDeleteParams {
    pub key: String,
}

#[derive(Debug, Default, Serialize, Deserialize, JsonSchema)]
pub struct KvListParams {
    #[serde(default)]
    pub prefix: Option<String>,
}

fn developer_instructions() -> &'static str {
    if cfg!(windows) {
        indoc! {"
            Use the developer extension to build software and operate a terminal.

            Make sure to use the tools *efficiently* - reading all the content you need in as few
            iterations as possible and then making the requested edits or running commands. You are
            responsible for managing your context window, and to minimize unnecessary turns which
            cost the user money.

            For editing software, prefer the flow of using tree to understand the codebase structure
            and file sizes. When you need to search, prefer findstr or Select-String (via shell).
            Then use type or Get-Content to gather the context you need, always reading before
            editing. Use write and edit to efficiently make changes. Test and verify as appropriate.
        "}
    } else {
        indoc! {"
            Use the developer extension to build software and operate a terminal.

            Make sure to use the tools *efficiently* - reading all the content you need in as few
            iterations as possible and then making the requested edits or running commands. You are
            responsible for managing your context window, and to minimize unnecessary turns which
            cost the user money.

            For editing software, prefer the flow of using tree to understand the codebase structure
            and file sizes. When you need to search, prefer rg which correctly respects gitignored
            content. Then use cat or sed to gather the context you need, always reading before editing.
            Use write and edit to efficiently make changes. Test and verify as appropriate.

            When running Python scripts or commands, always use `python3` instead of `python`.
        "}
    }
}

impl DeveloperClient {
    pub fn new(context: PlatformExtensionContext) -> Result<Self> {
        let info = InitializeResult::new(ServerCapabilities::builder().enable_tools().build())
            .with_server_info(Implementation::new(EXTENSION_NAME, "1.0.0").with_title("Developer"))
            .with_instructions(developer_instructions());

        Ok(Self {
            info,
            shell_tool: Arc::new(ShellTool::new(context.use_login_shell_path)?),
            edit_tools: Arc::new(EditTools::new()),
            tree_tool: Arc::new(TreeTool::new()),
            image_tool: Arc::new(ImageTool::new()),
            session_kv_store: Arc::new(std::sync::RwLock::new(HashMap::new())),
        })
    }

    fn schema<T: JsonSchema>() -> JsonObject {
        serde_json::to_value(schema_for!(T))
            .expect("schema serialization should succeed")
            .as_object()
            .expect("schema should serialize to an object")
            .clone()
    }

    pub fn parse_args<T: serde::de::DeserializeOwned>(
        arguments: Option<JsonObject>,
    ) -> Result<T, String> {
        let value = arguments
            .map(Value::Object)
            .ok_or_else(|| "Missing arguments".to_string())?;
        serde_json::from_value(value).map_err(|e| format!("Failed to parse arguments: {e}"))
    }

    fn text_result(text: impl Into<String>) -> CallToolResult {
        CallToolResult::success(vec![Content::text(text.into()).with_priority(0.0)])
    }

    fn kv_set(&self, session_id: &str, params: KvSetParams) -> CallToolResult {
        let mut store = self.session_kv_store.write().unwrap();
        let session_store = store.entry(session_id.to_string()).or_default();
        session_store.insert(params.key.clone(), params.value.clone());
        Self::text_result(format!("stored '{}'", params.key))
    }

    fn kv_get(&self, session_id: &str, params: KvGetParams) -> CallToolResult {
        let store = self.session_kv_store.read().unwrap();
        if let Some(value) = store
            .get(session_id)
            .and_then(|session_store| session_store.get(&params.key))
        {
            return Self::text_result(value.clone());
        }

        Self::text_result(format!("not found: '{}'", params.key))
    }

    fn kv_delete(&self, session_id: &str, params: KvDeleteParams) -> CallToolResult {
        let mut store = self.session_kv_store.write().unwrap();
        let removed = store
            .get_mut(session_id)
            .and_then(|session_store| session_store.remove(&params.key));
        if removed.is_some() {
            Self::text_result(format!("deleted '{}'", params.key))
        } else {
            Self::text_result(format!("not found: '{}'", params.key))
        }
    }

    fn kv_list(&self, session_id: &str, params: KvListParams) -> CallToolResult {
        let store = self.session_kv_store.read().unwrap();
        let Some(session_store) = store.get(session_id) else {
            return Self::text_result("empty");
        };

        let mut rows: Vec<(String, String)> = session_store
            .iter()
            .filter(|(key, _)| {
                params
                    .prefix
                    .as_ref()
                    .is_none_or(|prefix| key.starts_with(prefix))
            })
            .map(|(k, v)| (k.clone(), v.clone()))
            .collect();
        rows.sort_by(|a, b| a.0.cmp(&b.0));

        if rows.is_empty() {
            return Self::text_result("empty");
        }

        let output = rows
            .into_iter()
            .map(|(k, v)| format!("{k}={v}"))
            .collect::<Vec<_>>()
            .join("\n");
        Self::text_result(output)
    }

    pub(crate) fn get_tools() -> Vec<Tool> {
        vec![
            Tool::new(
                "write".to_string(),
                "Create a new file or overwrite an existing file. Creates parent directories if needed.".to_string(),
                Self::schema::<FileWriteParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("Write".to_string()),
                Some(false),
                Some(true),
                Some(false),
                Some(false),
            )),
            Tool::new(
                "edit".to_string(),
                "Edit a file by finding and replacing text. The before text must match exactly and uniquely. Use empty after text to delete.".to_string(),
                Self::schema::<FileEditParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("Edit".to_string()),
                Some(false),
                Some(true),
                Some(false),
                Some(false),
            )),
            Tool::new(
                "shell".to_string(),
                format!(
                    "Execute a shell command in the current dir. Commands run under `{shell}` \
                     (set GOOSE_SHELL to override) - write command strings in that shell's \
                     syntax. Returns an object with stdout and stderr as separate fields. The \
                     output of each stream is limited to up to 2000 lines, and longer outputs \
                     will be saved to a temporary file.",
                    shell = shell_display_name(),
                ),
                Self::schema::<ShellParams>(),
            )
            .with_output_schema::<ShellOutput>()
            .annotate(ToolAnnotations::from_raw(
                Some("Shell".to_string()),
                Some(false),
                Some(true),
                Some(false),
                Some(true),
            )),
            Tool::new(
                "tree".to_string(),
                "List a directory tree with line counts. Traversal respects .gitignore rules.".to_string(),
                Self::schema::<TreeParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("Tree".to_string()),
                Some(true),
                Some(false),
                Some(true),
                Some(false),
            )),
            Tool::new(
                "read_image".to_string(),
                "Read an image from a local file path or http(s) URL and return it as image content for the model to inspect. Supports png, jpeg, gif, and webp.".to_string(),
                Self::schema::<ImageReadParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("Read Image".to_string()),
                Some(true),
                Some(false),
                Some(true),
                Some(false),
            )),
            Tool::new(
                "kv_set".to_string(),
                "Set a session-scoped volatile key-value entry (RAM only, cleared when goose process exits).".to_string(),
                Self::schema::<KvSetParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("KV Set".to_string()),
                Some(false),
                Some(false),
                Some(true),
                Some(false),
            )),
            Tool::new(
                "kv_get".to_string(),
                "Get a session-scoped volatile key value by key (RAM only).".to_string(),
                Self::schema::<KvGetParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("KV Get".to_string()),
                Some(true),
                Some(false),
                Some(true),
                Some(false),
            )),
            Tool::new(
                "kv_delete".to_string(),
                "Delete a key from the session-scoped volatile key-value store (RAM only).".to_string(),
                Self::schema::<KvDeleteParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("KV Delete".to_string()),
                Some(false),
                Some(false),
                Some(true),
                Some(false),
            )),
            Tool::new(
                "kv_list".to_string(),
                "List session-scoped volatile key-value entries as key=value lines; optional prefix filter.".to_string(),
                Self::schema::<KvListParams>(),
            )
            .annotate(ToolAnnotations::from_raw(
                Some("KV List".to_string()),
                Some(true),
                Some(false),
                Some(true),
                Some(false),
            )),
        ]
    }
}

#[async_trait]
impl McpClientTrait for DeveloperClient {
    async fn list_tools(
        &self,
        _session_id: &str,
        _next_cursor: Option<String>,
        _cancellation_token: CancellationToken,
    ) -> Result<ListToolsResult, Error> {
        Ok(ListToolsResult {
            tools: Self::get_tools(),
            next_cursor: None,
            meta: None,
        })
    }

    async fn call_tool(
        &self,
        ctx: &ToolCallContext,
        name: &str,
        arguments: Option<JsonObject>,
        _cancel_token: CancellationToken,
    ) -> Result<CallToolResult, Error> {
        let working_dir = ctx.working_dir.as_deref();
        match name {
            "shell" => match Self::parse_args::<ShellParams>(arguments) {
                Ok(params) => Ok(self.shell_tool.shell_with_cwd(params, working_dir).await),
                Err(error) => Ok(ShellTool::error_result(&format!("Error: {error}"), None)),
            },
            "write" => match Self::parse_args::<FileWriteParams>(arguments) {
                Ok(params) => Ok(self.edit_tools.file_write_with_cwd(params, working_dir)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "edit" => match Self::parse_args::<FileEditParams>(arguments) {
                Ok(params) => Ok(self.edit_tools.file_edit_with_cwd(params, working_dir)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "tree" => match Self::parse_args::<TreeParams>(arguments) {
                Ok(params) => Ok(self.tree_tool.tree_with_cwd(params, working_dir)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "read_image" => match Self::parse_args::<ImageReadParams>(arguments) {
                Ok(params) => Ok(self
                    .image_tool
                    .image_read_with_cwd(params, working_dir)
                    .await),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "kv_set" => match Self::parse_args::<KvSetParams>(arguments) {
                Ok(params) => Ok(self.kv_set(&ctx.session_id, params)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "kv_get" => match Self::parse_args::<KvGetParams>(arguments) {
                Ok(params) => Ok(self.kv_get(&ctx.session_id, params)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "kv_delete" => match Self::parse_args::<KvDeleteParams>(arguments) {
                Ok(params) => Ok(self.kv_delete(&ctx.session_id, params)),
                Err(error) => Ok(CallToolResult::error(vec![Content::text(format!(
                    "Error: {error}"
                ))
                .with_priority(0.0)])),
            },
            "kv_list" => {
                let params = match arguments {
                    Some(_) => match Self::parse_args::<KvListParams>(arguments) {
                        Ok(params) => params,
                        Err(error) => {
                            return Ok(CallToolResult::error(vec![Content::text(format!(
                                "Error: {error}"
                            ))
                            .with_priority(0.0)]));
                        }
                    },
                    None => KvListParams::default(),
                };
                Ok(self.kv_list(&ctx.session_id, params))
            }
            _ => Ok(CallToolResult::error(vec![Content::text(format!(
                "Error: Unknown tool: {name}"
            ))
            .with_priority(0.0)])),
        }
    }

    fn get_info(&self) -> Option<&InitializeResult> {
        Some(&self.info)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::session::SessionManager;
    use rmcp::model::RawContent;
    use rmcp::object;
    use std::fs;

    #[test]
    fn developer_tools_are_flat() {
        let names: Vec<String> = DeveloperClient::get_tools()
            .into_iter()
            .map(|t| t.name.to_string())
            .collect();

        assert_eq!(
            names,
            vec![
                "write",
                "edit",
                "shell",
                "tree",
                "read_image",
                "kv_set",
                "kv_get",
                "kv_delete",
                "kv_list"
            ]
        );
    }

    fn test_context(data_dir: std::path::PathBuf) -> PlatformExtensionContext {
        PlatformExtensionContext {
            extension_manager: None,
            session_manager: Arc::new(SessionManager::new(data_dir)),
            session: None,
            use_login_shell_path: false,
        }
    }

    fn first_text(result: &CallToolResult) -> &str {
        match &result.content[0].raw {
            RawContent::Text(text) => &text.text,
            _ => panic!("expected text content"),
        }
    }

    #[tokio::test]
    async fn developer_client_uses_working_dir_for_file_tools() {
        let temp = tempfile::tempdir().unwrap();
        let client = DeveloperClient::new(test_context(temp.path().join("sessions"))).unwrap();
        let cwd = temp.path().join("workspace");
        fs::create_dir_all(&cwd).unwrap();

        let ctx = ToolCallContext::new("session".to_owned(), Some(cwd.clone()), None);
        let write = client
            .call_tool(
                &ctx,
                "write",
                Some(object!({
                    "path": "notes.txt",
                    "content": "first line"
                })),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(write.is_error, Some(false));
        assert_eq!(
            fs::read_to_string(cwd.join("notes.txt")).unwrap(),
            "first line"
        );

        let edit = client
            .call_tool(
                &ctx,
                "edit",
                Some(object!({
                    "path": "notes.txt",
                    "before": "first",
                    "after": "updated"
                })),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(edit.is_error, Some(false));
        assert_eq!(
            fs::read_to_string(cwd.join("notes.txt")).unwrap(),
            "updated line"
        );
    }

    #[cfg(not(windows))]
    #[tokio::test]
    async fn developer_client_uses_working_dir_for_shell_tool() {
        let temp = tempfile::tempdir().unwrap();
        let client = DeveloperClient::new(test_context(temp.path().join("sessions"))).unwrap();
        let cwd = temp.path().join("workspace");
        fs::create_dir_all(&cwd).unwrap();

        let ctx = ToolCallContext::new("session".to_owned(), Some(cwd.clone()), None);
        let result = client
            .call_tool(
                &ctx,
                "shell",
                Some(object!({
                    "command": "pwd"
                })),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(result.is_error, Some(false));
        let observed = std::fs::canonicalize(first_text(&result)).unwrap();
        let expected = std::fs::canonicalize(&cwd).unwrap();
        assert_eq!(observed, expected);
    }

    #[tokio::test]
    async fn developer_client_kv_persists_per_session() {
        let temp = tempfile::tempdir().unwrap();
        let client = DeveloperClient::new(test_context(temp.path().join("sessions"))).unwrap();
        let ctx = ToolCallContext::new("session-a".to_owned(), None, None);

        let set_res = client
            .call_tool(
                &ctx,
                "kv_set",
                Some(object!({"key": "token", "value": "abc123"})),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(set_res.is_error, Some(false));

        let get_res = client
            .call_tool(
                &ctx,
                "kv_get",
                Some(object!({"key": "token"})),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(first_text(&get_res), "abc123");

        let list_res = client
            .call_tool(&ctx, "kv_list", None, CancellationToken::new())
            .await
            .unwrap();
        assert!(first_text(&list_res).contains("token=abc123"));
    }

    #[tokio::test]
    async fn developer_client_kv_isolated_by_session_id() {
        let temp = tempfile::tempdir().unwrap();
        let client = DeveloperClient::new(test_context(temp.path().join("sessions"))).unwrap();

        let ctx_a = ToolCallContext::new("session-a".to_owned(), None, None);
        let ctx_b = ToolCallContext::new("session-b".to_owned(), None, None);

        let _ = client
            .call_tool(
                &ctx_a,
                "kv_set",
                Some(object!({"key": "mode", "value": "strict"})),
                CancellationToken::new(),
            )
            .await
            .unwrap();

        let get_b = client
            .call_tool(
                &ctx_b,
                "kv_get",
                Some(object!({"key": "mode"})),
                CancellationToken::new(),
            )
            .await
            .unwrap();
        assert_eq!(first_text(&get_b), "not found: 'mode'");
    }
}
