// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2026 Lucas Gallindo

use rmcp::{
    handler::server::{router::tool::ToolRouter, wrapper::Parameters},
    model::{
        CallToolResult, Content, ErrorData, Implementation, InitializeResult, ServerCapabilities,
        ServerInfo,
    },
    schemars::JsonSchema,
    service::RequestContext,
    tool, tool_handler, tool_router, RoleServer, ServerHandler,
};
use serde::{Deserialize, Serialize};
use std::env;

const DEFAULT_MAX_RESULTS: usize = 3;
const SEARXNG_ENV: &str = "GOOSE_SEARXNG_URL";

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

fn searxng_base_url() -> Option<String> {
    env::var(SEARXNG_ENV)
        .ok()
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

async fn search_duckduckgo_embedded(query: &str, max_results: usize) -> String {
    let provider = websearch::providers::DuckDuckGoProvider::new();
    let opts = websearch::SearchOptions {
        query: query.to_string(),
        provider: Box::new(provider),
        ..Default::default()
    };

    let mut out = String::new();
    if let Ok(results) = websearch::web_search(opts).await {
        for (i, res) in results.iter().take(max_results).enumerate() {
            out.push_str(&format!("{}. {} — {}\n", i + 1, res.title, res.url));
        }
    }
    if out.is_empty() {
        out.push_str("No DuckDuckGo results.\n");
    }
    out
}

async fn search_searxng_embedded(query: &str, max_results: usize) -> Option<String> {
    let base = searxng_base_url()?;
    let client = searxng_client::SearXNGClient::new(&base, searxng_client::ResponseFormat::Json);
    match client.search(query).send_get_num(max_results).await {
        Ok(res) => {
            let mut out = String::new();
            for (i, r) in res.iter().enumerate() {
                let title = match r {
                    searxng_client::response::SearchResult::MainResult(m) => m.title.clone(),
                    searxng_client::response::SearchResult::LegacyResult(l) => l.title.clone(),
                };
                out.push_str(&format!("{}. {}\n", i + 1, title));
            }
            if out.is_empty() {
                out.push_str("No SearXNG results.\n");
            }
            Some(out)
        }
        Err(e) => Some(format!("SearXNG error ({base}): {e}\n")),
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
        name = "search_web",
        description = "Embedded web search (DuckDuckGo, no API key). Optional SearXNG when GOOSE_SEARXNG_URL is set."
    )]
    pub async fn search_web(
        &self,
        params: Parameters<SearchParams>,
        _context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        let query = params.0.query;
        let mut body = format!("Query: {query}\n\n## DuckDuckGo\n");
        body.push_str(&search_duckduckgo_embedded(&query, DEFAULT_MAX_RESULTS).await);
        if let Some(searxng) = search_searxng_embedded(&query, DEFAULT_MAX_RESULTS).await {
            body.push_str("\n## SearXNG\n");
            body.push_str(&searxng);
        }
        Ok(CallToolResult::success(vec![Content::text(body)]))
    }

    /// Back-compat alias for older recipes/tests.
    #[tool(
        name = "search_websearch_crate",
        description = "Alias for search_web (embedded DuckDuckGo via websearch crate)."
    )]
    pub async fn search_websearch_crate(
        &self,
        params: Parameters<SearchParams>,
        context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        self.search_web(params, context).await
    }

    #[tool(
        name = "search_searxng",
        description = "Search a local SearXNG instance (GOOSE_SEARXNG_URL, default http://localhost:8080)."
    )]
    pub async fn search_searxng(
        &self,
        params: Parameters<SearchParams>,
        _context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        let query = params.0.query;
        let base = searxng_base_url().unwrap_or_else(|| "http://localhost:8080".to_string());
        let client = searxng_client::SearXNGClient::new(&base, searxng_client::ResponseFormat::Json);
        match client.search(&query).send_get_num(DEFAULT_MAX_RESULTS).await {
            Ok(res) => {
                let mut out = String::new();
                for (i, r) in res.iter().enumerate() {
                    let title = match r {
                        searxng_client::response::SearchResult::MainResult(m) => m.title.clone(),
                        searxng_client::response::SearchResult::LegacyResult(l) => l.title.clone(),
                    };
                    out.push_str(&format!("{}. {}\n", i + 1, title));
                }
                if out.is_empty() {
                    out.push_str("No results.\n");
                }
                Ok(CallToolResult::success(vec![Content::text(out)]))
            }
            Err(e) => Ok(CallToolResult::success(vec![Content::text(format!(
                "SearXNG error ({base}): {e}"
            ))])),
        }
    }

    #[tool(
        name = "uber_search",
        description = "Search DuckDuckGo and optional SearXNG; returns unified markdown sections."
    )]
    pub async fn uber_search(
        &self,
        params: Parameters<SearchParams>,
        context: RequestContext<RoleServer>,
    ) -> Result<CallToolResult, ErrorData> {
        self.search_web(params, context).await
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
            .with_instructions(
                "Embedded web search (no API keys). Set GOOSE_SEARXNG_URL for optional SearXNG."
                    .to_string(),
            )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rmcp::ServerHandler;

    #[tokio::test]
    async fn test_websearch_server_exposes_tools() {
        let server = WebsearchServer::new();
        let info = server.get_info();
        assert_eq!(info.server_info.name, "goose-websearch");
        assert!(info.capabilities.tools.is_some());
    }

    #[test]
    fn test_searxng_env_empty_is_none() {
        let _guard = env_lock();
        env::remove_var(SEARXNG_ENV);
        assert!(searxng_base_url().is_none());
    }

    fn env_lock() -> impl Drop {
        use std::sync::{Mutex, MutexGuard};
        static LOCK: Mutex<()> = Mutex::new(());
        struct Guard(MutexGuard<'static, ()>);
        impl Drop for Guard {
            fn drop(&mut self) {}
        }
        Guard(LOCK.lock().unwrap())
    }
}
