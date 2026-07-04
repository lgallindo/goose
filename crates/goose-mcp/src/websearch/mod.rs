use rmcp::{
    handler::server::{router::tool::ToolRouter, wrapper::Parameters},
    model::{
        CallToolResult, Content, ErrorData, Implementation, InitializeResult, ServerCapabilities, ServerInfo,
    },
    schemars::JsonSchema,
    service::RequestContext,
    tool, tool_handler, tool_router, RoleServer, ServerHandler,
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, JsonSchema)]
pub struct SearchParams {
    /// The search query
    pub query: String,
}

#[derive(Clone)]
pub struct WebsearchServer {
    tool_router: ToolRouter<Self>,
}

impl Default for WebsearchServer {
    fn default() -> Self {
        Self::new()
    }
}

#[tool_router(router = tool_router)]
impl WebsearchServer {
    pub fn new() -> Self {
        Self {
            tool_router: Self::tool_router(),
        }
    }

    #[tool(
        name = "search_websearch_crate",
        description = "Performs a web search using the websearch crate."
    )]
    pub async fn search_websearch(
        &self,
        params: Parameters<SearchParams>,
        _context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        let query = params.0.query;
        let mut results_str = String::new();
        
        let provider = websearch::providers::DuckDuckGoProvider::new();
        let opts = websearch::SearchOptions { 
            query: query.clone(), 
            provider: Box::new(provider), 
            ..Default::default() 
        };
        
        if let Ok(results) = websearch::web_search(opts).await {
            for res in results.iter().take(3) {
                results_str.push_str(&format!("{}: {}\n", res.title, res.url));
            }
        }
        if results_str.is_empty() { results_str = "No results".to_string() }
        
        Ok(CallToolResult::success(vec![Content::text(format!("Websearch Results:\n{}", results_str))]))
    }

    #[tool(
        name = "search_duckduckgo_cli_crate",
        description = "Performs a DuckDuckGo search using duckduckgo-search-cli logic."
    )]
    pub async fn search_duckduckgo(
        &self,
        params: Parameters<SearchParams>,
        _context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        // TDD stub: use CLI fallback for speed of test
        let query = params.0.query;
        let out = std::process::Command::new("cargo")
            .args(["run", "--bin", "duckduckgo-search-cli", "--", &query, "--max-results", "3", "--format", "json"])
            .output();
            
        let res = match out {
            Ok(output) if output.status.success() => String::from_utf8_lossy(&output.stdout).to_string(),
            _ => format!("Fallback CLI failed for '{}'", query),
        };
        
        Ok(CallToolResult::success(vec![Content::text(format!("DDG CLI Results:\n{}", res))]))
    }

    #[tool(
        name = "search_searxng_client_crate",
        description = "Performs a search using searxng-client crate against a local SearXNG instance."
    )]
    pub async fn search_searxng(
        &self,
        params: Parameters<SearchParams>,
        _context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        let query = params.0.query;
        let client = searxng_client::SearXNGClient::new("http://localhost:8080", searxng_client::ResponseFormat::Json);
        
        match client.search(&query).send_get_num(3).await {
            Ok(res) => {
                let mut out = String::new();
                for r in res.iter() {
                    let title = match r {
                        searxng_client::response::SearchResult::MainResult(m) => m.title.clone(),
                        searxng_client::response::SearchResult::LegacyResult(l) => l.title.clone(),
                    };
                    out.push_str(&format!("* {}\n", title));
                }
                Ok(CallToolResult::success(vec![Content::text(out)]))
            },
            Err(e) => {
                Ok(CallToolResult::success(vec![Content::text(format!("SearXNG error: {}", e))]))
            }
        }
    }

    #[tool(
        name = "uber_search",
        description = "Performs a web search across websearch, duckduckgo-search-cli, and searxng-client. Returns a unified result."
    )]
    pub async fn uber_search(
        &self,
        params: Parameters<SearchParams>,
        context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        let w = self.search_websearch(params.clone(), context.clone());
        let d = self.search_duckduckgo(params.clone(), context.clone());
        let s = self.search_searxng(params.clone(), context.clone());
        
        let (w_res, d_res, s_res) = futures::join!(w, d, s);
        
        let mut unified = String::from("=== UNION ALL RESULTS ===\n\n");
        if let Ok(res) = w_res { unified.push_str(&format!("{:?}", res.content[0])); unified.push_str("\n\n"); }
        if let Ok(res) = d_res { unified.push_str(&format!("{:?}", res.content[0])); unified.push_str("\n\n"); }
        if let Ok(res) = s_res { unified.push_str(&format!("{:?}", res.content[0])); unified.push_str("\n\n"); }
        
        Ok(CallToolResult::success(vec![Content::text(unified)]))
    }
}

#[tool_handler(router = self.tool_router)]
impl ServerHandler for WebsearchServer {
    fn get_info(&self) -> ServerInfo {
        InitializeResult::new(ServerCapabilities::builder().enable_tools().build())
            .with_server_info(Implementation::new(
                "goose-websearch",
                env!("CARGO_PKG_VERSION"),
            ))
            .with_instructions("A server that provides web search utilities using multiple open-source crates.".to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_websearch_tools_exist() {
        let server = WebsearchServer::new();
        assert!(server.tool_router.has_tool("search_websearch_crate"));
        assert!(server.tool_router.has_tool("search_duckduckgo_cli_crate"));
        assert!(server.tool_router.has_tool("search_searxng_client_crate"));
        assert!(server.tool_router.has_tool("uber_search"));
    }
}
