[![Go Report Card](https://goreportcard.com/badge/github.com/github/github-mcp-s
erver)](https://goreportcard.com/report/github.com/github/github-mcp-server)

# GitHub MCP Server

The GitHub MCP Server connects AI tools directly to GitHub's platform. This give
s AI agents, assistants, and chatbots the ability to read repositories and code
files, manage issues and PRs, analyze code, and automate workflows. All through
natural language interactions.

### Use Cases

- Repository Management: Browse and query code, search files, analyze commits, a
nd understand project structure across any repository you have access to.
- Issue & PR Automation: Create, update, and manage issues and pull requests. Le
t AI help triage bugs, review code changes, and maintain project boards.
- CI/CD & Workflow Intelligence: Monitor GitHub Actions workflow runs, analyze b
uild failures, manage releases, and get insights into your development pipeline.
- Code Analysis: Examine security findings, review Dependabot alerts, understand
 code patterns, and get comprehensive insights into your codebase.
- Team Collaboration: Access discussions, manage notifications, analyze team act
ivity, and streamline processes for your team.

Built for developers who want to connect their AI tools to GitHub context and ca
pabilities, from simple natural language queries to complex multi-step agent wor
kflows.

---

## Remote GitHub MCP Server

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Server-0098F
F?style=flat-square&logo=visualstudiocode&logoColor=white)](https://insiders.vsc
ode.dev/redirect/mcp/install?name=github&config=%7B%22type%22%3A%20%22http%22%2C
%22url%22%3A%20%22https%3A%2F%2Fapi.githubcopilot.com%2Fmcp%2F%22%7D) [![Install
 in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install_Serv
er-24bfa5?style=flat-square&logo=visualstudiocode&logoColor=white)](https://insi
ders.vscode.dev/redirect/mcp/install?name=github&config=%7B%22type%22%3A%20%22ht
tp%22%2C%22url%22%3A%20%22https%3A%2F%2Fapi.githubcopilot.com%2Fmcp%2F%22%7D&qua
lity=insiders) [![Install in Visual Studio](https://img.shields.io/badge/Visual_
Studio-Install_Server-C16FDE?style=flat-square&logo=visualstudio&logoColor=white
)](https://aka.ms/vs/mcp-install?%7B%22name%22%3A%22github%22%2C%22gallery%22%3A
true%2C%22url%22%3A%22https%3A%2F%2Fapi.githubcopilot.com%2Fmcp%2F%22%7D)

The remote GitHub MCP Server is hosted by GitHub and provides the easiest method
 for getting up and running. If your MCP host does not support remote MCP server
s, don't worry! You can use the [local version of the GitHub MCP Server](https:/
/github.com/github/github-mcp-server?tab=readme-ov-file#local-github-mcp-server)
 instead.

### Prerequisites

1. A compatible MCP host with remote server support (VS Code 1.101+, Claude Desk
top, Cursor, Windsurf, etc.)
2. Any applicable [policies enabled](https://github.com/github/github-mcp-server
/blob/main/docs/policies-and-governance.md)

### Install in VS Code

For quick installation, use one of the one-click install buttons above. Once you
 complete that flow, toggle Agent mode (located by the Copilot Chat text input)
and the server will start. Make sure you're using [VS Code 1.101](https://code.v
isualstudio.com/updates/v1_101) or [later](https://code.visualstudio.com/updates
) for remote MCP and OAuth support.

Alternatively, to manually configure VS Code, choose the appropriate JSON block
from the examples below and add it to your host configuration:

<table>
<tr><th>Using OAuth</th><th>Using a GitHub PAT</th></tr>
<tr><th align=left colspan=2>VS Code (version 1.101 or greater)</th></tr>
<tr valign=top>
<td>

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

</td>
<td>

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${input:github_mcp_pat}"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "github_mcp_pat",
      "description": "GitHub Personal Access Token",
      "password": true
    }
  ]
}
```

</td>
</tr>
</table>

### Install in other MCP hosts

- **[Copilot CLI](/docs/installation-guides/install-copilot-cli.md)** - Installa
tion guide for GitHub Copilot CLI
- **[GitHub Copilot in other IDEs](/docs/installation-guides/install-other-copil
ot-ides.md)** - Installation for JetBrains, Visual Studio, Eclipse, and Xcode wi
th GitHub Copilot
- **[Claude Applications](/docs/installation-guides/install-claude.md)** - Insta
llation guide for Claude Desktop and Claude Code CLI
- **[Codex](/docs/installation-guides/install-codex.md)** - Installation guide f
or OpenAI Codex
- **[Cursor](/docs/installation-guides/install-cursor.md)** - Installation guide
 for Cursor IDE
- **[OpenCode](/docs/installation-guides/install-opencode.md)** - Installation g
uide for the OpenCode terminal agent
- **[Windsurf](/docs/installation-guides/install-windsurf.md)** - Installation g
uide for Windsurf IDE
- **[Zed](/docs/installation-guides/install-zed.md)** - Installation guide for Z
ed editor
- **[Rovo Dev CLI](/docs/installation-guides/install-rovo-dev-cli.md)** - Instal
lation guide for Rovo Dev CLI

> **Note:** Each MCP host application needs to configure a GitHub App or OAuth A
pp to support remote access via OAuth. Any host application that supports remote
 MCP servers should support the remote GitHub server with PAT authentication. Co
nfiguration details and support levels vary by host. Make sure to refer to the h
ost application's documentation for more info.

### Configuration

#### Toolset configuration

See [Remote Server Documentation](docs/remote-server.md) for full details on rem
ote server configuration, toolsets, headers, and advanced usage. This file provi
des comprehensive instructions and examples for connecting, customizing, and ins
talling the remote GitHub MCP Server in VS Code and other MCP hosts.

When no toolsets are specified, [default toolsets](#default-toolset) are used.

#### Insiders Mode

> **Try new features early!** The remote server offers an insiders version with
early access to new features and experimental tools.

<table>
<tr><th>Using URL Path</th><th>Using Header</th></tr>
<tr valign=top>
<td>

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/insiders"
    }
  }
}
```

</td>
<td>

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "X-MCP-Insiders": "true"
      }
    }
  }
}
```

</td>
</tr>
</table>

See [Remote Server Documentation](docs/remote-server.md#insiders-mode) for more
details and examples, and [Insiders Features](docs/insiders-features.md) for a f
ull list of what's available.

#### GitHub Enterprise

##### GitHub Enterprise Cloud with data residency (ghe.com)

GitHub Enterprise Cloud can also make use of the remote server.

Example for `https://octocorp.ghe.com` with GitHub PAT token:

```
{
    ...
    "github-octocorp": {
      "type": "http",
      "url": "https://copilot-api.octocorp.ghe.com/mcp",
      "headers": {
        "Authorization": "Bearer ${input:github_mcp_pat}"
      }
    },
    ...
}
```

> **Note:** When using OAuth with GitHub Enterprise with VS Code and GitHub Copi
lot, you also need to configure your VS Code settings to point to your GitHub En
terprise instance - see [Authenticate from VS Code](https://docs.github.com/en/e
nterprise-cloud@latest/copilot/how-tos/configure-personal-settings/authenticate-
to-ghecom)

##### GitHub Enterprise Server

GitHub Enterprise Server does not support remote server hosting. Please refer to
 [GitHub Enterprise Server and Enterprise Cloud with data residency (ghe.com)](#
github-enterprise-server-and-enterprise-cloud-with-data-residency-ghecom) from t
he local server configuration.

---

## Local GitHub MCP Server

[![Install with Docker in VS Code](https://img.shields.io/badge/VS_Code-Install_
Server-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://
insiders.vscode.dev/redirect/mcp/install?name=github&config=%7B%22command%22%3A%
22docker%22%2C%22args%22%3A%5B%22run%22%2C%22-i%22%2C%22--rm%22%2C%22-p%22%2C%22
127.0.0.1%3A8085%3A8085%22%2C%22-e%22%2C%22GITHUB_OAUTH_CALLBACK_PORT%22%2C%22gh
cr.io%2Fgithub%2Fgithub-mcp-server%22%5D%2C%22env%22%3A%7B%22GITHUB_OAUTH_CALLBA
CK_PORT%22%3A%228085%22%7D%7D) [![Install with Docker in VS Code Insiders](https
://img.shields.io/badge/VS_Code_Insiders-Install_Server-24bfa5?style=flat-square
&logo=visualstudiocode&logoColor=white)](https://insiders.vscode.dev/redirect/mc
p/install?name=github&config=%7B%22command%22%3A%22docker%22%2C%22args%22%3A%5B%
22run%22%2C%22-i%22%2C%22--rm%22%2C%22-p%22%2C%22127.0.0.1%3A8085%3A8085%22%2C%2
2-e%22%2C%22GITHUB_OAUTH_CALLBACK_PORT%22%2C%22ghcr.io%2Fgithub%2Fgithub-mcp-ser
ver%22%5D%2C%22env%22%3A%7B%22GITHUB_OAUTH_CALLBACK_PORT%22%3A%228085%22%7D%7D&q
uality=insiders) [![Install with Docker in Visual Studio](https://img.shields.io
/badge/Visual_Studio-Install_Server-C16FDE?style=flat-square&logo=visualstudio&l
ogoColor=white)](https://aka.ms/vs/mcp-install?%7B%22name%22%3A%22github%22%2C%2
2command%22%3A%22docker%22%2C%22args%22%3A%5B%22run%22%2C%22-i%22%2C%22--rm%22%2
C%22-p%22%2C%22127.0.0.1%3A8085%3A8085%22%2C%22-e%22%2C%22GITHUB_OAUTH_CALLBACK_
PORT%3D8085%22%2C%22ghcr.io%2Fgithub%2Fgithub-mcp-server%22%5D%7D)

### Prerequisites

1. To run the server in a container, you will need to have [Docker](https://www.
docker.com/) installed.
2. Once Docker is installed, you will also need to ensure Docker is running. The
 Docker image is available at `ghcr.io/github/github-mcp-server`. The image is p
ublic; if you get errors on pull, you may have an expired token and need to `doc
ker logout ghcr.io`.
3. **Authentication.** On github.com you don't need to create anything up front
— the one-click buttons above log you in with OAuth on first use (a browser-base
d flow; the token is kept in memory only). The Docker buttons publish a fixed ca
llback port (`127.0.0.1:8085`) so the container's login callback is reachable. S
ee **[Local Server OAuth Login](docs/oauth-login.md)** for how it works, headles
s/device-code fallback, and bringing your own OAuth or GitHub App (required for
GitHub Enterprise Server and `ghe.com`).

   Prefer a token? You can still authenticate with a [GitHub Personal Access Tok
en](https://github.com/settings/personal-access-tokens/new) by setting `GITHUB_P
ERSONAL_ACCESS_TOKEN` instead (it takes precedence over OAuth). The MCP server c
an use many of the GitHub APIs, so enable the permissions that you feel comforta
ble granting your AI tools (to learn more about access tokens, please check out
the [documentation](https://docs.github.com/en/authentication/keeping-your-accou
nt-and-data-secure/managing-your-personal-access-tokens)).

<details><summary><b>Handling PATs Securely</b></summary>

### Environment Variables (Recommended)

To keep your GitHub PAT secure and reusable across different MCP hosts:

1. **Store your PAT in environment variables**

   ```bash
   export GITHUB_PAT=your_token_here
   ```

   Or create a `.env` file:

   ```env
   GITHUB_PAT=your_token_here
   ```

2. **Protect your `.env` file**

   ```bash
   # Add to .gitignore to prevent accidental commits
   echo ".env" >> .gitignore
   ```

3. **Reference the token in configurations**

   ```bash
   # CLI usage
   claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PAT -- docker r
un -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server

   # In config files (where supported)
   "env": {
     "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_PAT"
   }
   ```

> **Note**: Environment variable support varies by host app and IDE. Some applic
ations (like Windsurf) require hardcoded tokens in config files.

### Token Security Best Practices

- **Minimum scopes**: Only grant necessary permissions
  - `repo` - Repository operations
  - `read:packages` - Docker image access
  - `read:org` - Organization team access
- **Separate tokens**: Use different PATs for different projects/environments
- **Regular rotation**: Update tokens periodically
- **Never commit**: Keep tokens out of version control
- **File permissions**: Restrict access to config files containing tokens

  ```bash
  chmod 600 ~/.your-app/config.json
  ```

</details>

### GitHub Enterprise Server and Enterprise Cloud with data residency (ghe.com)

The flag `--gh-host` and the environment variable `GITHUB_HOST` can be used to s
et
the hostname for GitHub Enterprise Server or GitHub Enterprise Cloud with data r
esidency.

- For GitHub Enterprise Server, prefix the hostname with the `https://` URI sche
me, as it otherwise defaults to `http://`, which GitHub Enterprise Server does n
ot support.
- For GitHub Enterprise Cloud with data residency, use `https://YOURSUBDOMAIN.gh
e.com` as the hostname.

``` json
"github": {
    "command": "docker",
    "args": [
    "run",
    "-i",
    "--rm",
    "-e",
    "GITHUB_PERSONAL_ACCESS_TOKEN",
    "-e",
    "GITHUB_HOST",
    "ghcr.io/github/github-mcp-server"
    ],
    "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}",
        "GITHUB_HOST": "https://<your GHES or ghe.com domain name>"
    }
}
```

## Installation

### Install in GitHub Copilot on VS Code

For quick installation, use one of the one-click install buttons above. Once you
 complete that flow, toggle Agent mode (located by the Copilot Chat text input)
and the server will start.

More about using MCP server tools in VS Code's [agent mode documentation](https:
//code.visualstudio.com/docs/copilot/chat/mcp-servers).

Install in GitHub Copilot on other IDEs (JetBrains, Visual Studio, Eclipse, etc.
)

Add one of the following JSON blocks to your IDE's MCP settings.

**Log in with OAuth (no token to create or store).** On github.com the official
image already includes the app credentials, so you provide none yourself: it run
s a browser-based login on first use and keeps the resulting token **in memory o
nly**. In Docker this needs a fixed callback port published to loopback so the c
ontainer's login callback is reachable:

```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "docker",
        "args": [
          "run",
          "-i",
          "--rm",
          "-p",
          "127.0.0.1:8085:8085",
          "-e",
          "GITHUB_OAUTH_CALLBACK_PORT",
          "ghcr.io/github/github-mcp-server"
        ],
        "env": {
          "GITHUB_OAUTH_CALLBACK_PORT": "8085"
        }
      }
    }
  }
}
```

See **[Local Server OAuth Login](docs/oauth-login.md)** for the native-binary fl
ow (no fixed port needed), the headless/device-code fallback, GitHub Enterprise
Server / `ghe.com`, and bringing your own OAuth or GitHub App.

**Or authenticate with a Personal Access Token.** Set `GITHUB_PERSONAL_ACCESS_TO
KEN` instead (it takes precedence over OAuth):

```json
{
  "mcp": {
    "inputs": [
      {
        "type": "promptString",
        "id": "github_token",
        "description": "GitHub Personal Access Token",
        "password": true
      }
    ],
    "servers": {
      "github": {
        "command": "docker",
        "args": [
          "run",
          "-i",
          "--rm",
          "-e",
          "GITHUB_PERSONAL_ACCESS_TOKEN",
          "ghcr.io/github/github-mcp-server"
        ],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}"
        }
      }
    }
  }
}
```

Optionally, you can add a similar example (i.e. without the mcp key) to a file c
alled `.vscode/mcp.json` in your workspace. This will allow you to share the con
figuration with other host applications that accept the same format.

<details>
<summary><b>Example JSON block without the MCP key included</b></summary>
<br>

```json
{
  "inputs": [
    {
      "type": "promptString",
      "id": "github_token",
      "description": "GitHub Personal Access Token",
      "password": true
    }
  ],
  "servers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}"
      }
    }
  }
}
```

</details>

### Install in Other MCP Hosts

For other MCP host applications, please refer to our installation guides:

- **[Copilot CLI](docs/installation-guides/install-copilot-cli.md)** - Installat
ion guide for GitHub Copilot CLI
- **[GitHub Copilot in other IDEs](/docs/installation-guides/install-other-copil
ot-ides.md)** - Installation for JetBrains, Visual Studio, Eclipse, and Xcode wi
th GitHub Copilot
- **[Claude Code & Claude Desktop](docs/installation-guides/install-claude.md)**
 - Installation guide for Claude Code and Claude Desktop
- **[Cursor](docs/installation-guides/install-cursor.md)** - Installation guide
for Cursor IDE
- **[Google Gemini CLI](docs/installation-guides/install-gemini-cli.md)** - Inst
allation guide for Google Gemini CLI
- **[OpenCode](docs/installation-guides/install-opencode.md)** - Installation gu
ide for the OpenCode terminal agent
- **[Windsurf](docs/installation-guides/install-windsurf.md)** - Installation gu
ide for Windsurf IDE
- **[Zed](docs/installation-guides/install-zed.md)** - Installation guide for Ze
d editor

For a complete overview of all installation options, see our **[Installation Gui
des Index](docs/installation-guides)**.

> **Note:** Any host application that supports local MCP servers should be able
to access the local GitHub MCP server. However, the specific configuration proce
ss, syntax and stability of the integration will vary by host application. While
 many may follow a similar format to the examples above, this is not guaranteed.
 Please refer to your host application's documentation for the correct MCP confi
guration syntax and setup process.

### Build from source

If you don't have Docker, you can use `go build` to build the binary in the
`cmd/github-mcp-server` directory, and use the `github-mcp-server stdio` command
 with the `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable set to your token.
 To specify the output location of the build, use the `-o` flag. You should conf
igure your server to use the built executable as its `command`. For example:

```JSON
{
  "mcp": {
    "servers": {
      "github": {
        "command": "/path/to/github-mcp-server",
        "args": ["stdio"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
        }
      }
    }
  }
}
```

### CLI utilities

The `github-mcp-server` binary includes a few CLI subcommands that are helpful f
or debugging and exploring the server.

- `github-mcp-server tool-search "<query>"` searches tools by name, description,
 and input parameter names. Use `--max-results` to return more matches.
Example (color output requires a TTY; use `docker run -t` (or `-it`) when runnin
g in Docker):
```bash
docker run -it --rm ghcr.io/github/github-mcp-server tool-search "issue" --max-r
esults 5
github-mcp-server tool-search "issue" --max-results 5
```

## Tool Configuration

The GitHub MCP Server supports enabling or disabling specific groups of function
alities via the `--toolsets` flag. This allows you to control which GitHub API c
apabilities are available to your AI tools. Enabling only the toolsets that you
need can help the LLM with tool choice and reduce the context size.

_Toolsets are not limited to Tools. Relevant MCP Resources and Prompts are also
included where applicable._

When no toolsets are specified, [default toolsets](#default-toolset) are used.

> **Looking for examples?** See the [Server Configuration Guide](./docs/server-c
onfiguration.md) for common recipes like minimal setups, read-only mode, and com
bining tools with toolsets.

#### Specifying Toolsets

To specify toolsets you want available to the LLM, you can pass an allow-list in
 two ways:

1. **Using Command Line Argument**:

   ```bash
   github-mcp-server --toolsets repos,issues,pull_requests,actions,code_security
   ```

2. **Using Environment Variable**:

   ```bash
   GITHUB_TOOLSETS="repos,issues,pull_requests,actions,code_security" ./github-m
cp-server
   ```

The environment variable `GITHUB_TOOLSETS` takes precedence over the command lin
e argument if both are provided.

#### Specifying Individual Tools

You can also configure specific tools using the `--tools` flag. Tools can be use
d independently or combined with toolsets for fine-grained control.

1. **Using Command Line Argument**:

   ```bash
   github-mcp-server --tools get_file_contents,issue_read,create_pull_request
   ```

2. **Using Environment Variable**:

   ```bash
   GITHUB_TOOLS="get_file_contents,issue_read,create_pull_request" ./github-mcp-
server
   ```

3. **Combining with Toolsets** (additive):

   ```bash
   github-mcp-server --toolsets repos,issues --tools get_gist
   ```

   This registers all tools from `repos` and `issues` toolsets, plus `get_gist`.

**Important Notes:**

- Tools and toolsets can be used together
- Read-only mode takes priority: write tools are skipped if `--read-only` is set
, even if explicitly requested via `--tools`
- Tool names must match exactly (e.g., `get_file_contents`, not `getFileContents
`). Invalid tool names will cause the server to fail at startup with an error me
ssage
- When tools are renamed, old names are preserved as aliases for backward compat
ibility. See [Tool Renaming](docs/tool-renaming.md) for details.

### Using Toolsets With Docker

When using Docker, you can pass the toolsets as environment variables:

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_TOOLSETS="repos,issues,pull_requests,actions,code_security" \
  ghcr.io/github/github-mcp-server
```

### Using Tools With Docker

When using Docker, you can pass specific tools as environment variables. You can
 also combine tools with toolsets:

```bash
# Tools only
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_TOOLS="get_file_contents,issue_read,create_pull_request" \
  ghcr.io/github/github-mcp-server

# Tools combined with toolsets (additive)
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_TOOLSETS="repos,issues" \
  -e GITHUB_TOOLS="get_gist" \
  ghcr.io/github/github-mcp-server
```

### Special toolsets

#### "all" toolset

The special toolset `all` can be provided to enable all available toolsets regar
dless of any other configuration:

```bash
./github-mcp-server --toolsets all
```

Or using the environment variable:

```bash
GITHUB_TOOLSETS="all" ./github-mcp-server
```

#### "default" toolset

The default toolset `default` is the configuration that gets passed to the serve
r if no toolsets are specified.

The default configuration is:

- context
- repos
- issues
- pull_requests
- users

To keep the default configuration and add additional toolsets:

```bash
GITHUB_TOOLSETS="default,stargazers" ./github-mcp-server
```

### Insiders Mode

The local GitHub MCP Server offers an insiders version with early access to new
features and experimental tools.

1. **Using Command Line Argument**:

   ```bash
   ./github-mcp-server --insiders
   ```

2. **Using Environment Variable**:

   ```bash
   GITHUB_INSIDERS=true ./github-mcp-server
   ```

When using Docker:

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_INSIDERS=true \
  ghcr.io/github/github-mcp-server
```

### Available Toolsets

The following sets of tools are available:

<!-- START AUTOMATED TOOLSETS -->
|     | Toolset                 | Description
                |
| --- | ----------------------- | ----------------------------------------------
--------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/person-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/oc
ticons/icons/person-light.png"><img src="pkg/octicons/icons/person-light.png" wi
dth="20" height="20" alt="person"></picture> | `context`               | **Stron
gly recommended**: Tools that provide context about the current user and GitHub
context you are operating in |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/workflow-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/
octicons/icons/workflow-light.png"><img src="pkg/octicons/icons/workflow-light.p
ng" width="20" height="20" alt="workflow"></picture> | `actions` | GitHub Action
s workflows and CI/CD operations |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/code-square-dark.png"><source media="(prefers-color-scheme: light)" srcset="p
kg/octicons/icons/code-square-light.png"><img src="pkg/octicons/icons/code-squar
e-light.png" width="20" height="20" alt="code-square"></picture> | `code_quality
` | GitHub Code Quality related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/codescan-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/
octicons/icons/codescan-light.png"><img src="pkg/octicons/icons/codescan-light.p
ng" width="20" height="20" alt="codescan"></picture> | `code_security` | Code se
curity related tools, such as GitHub Code Scanning |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/copilot-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/o
cticons/icons/copilot-light.png"><img src="pkg/octicons/icons/copilot-light.png"
 width="20" height="20" alt="copilot"></picture> | `copilot` | Copilot related t
ools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/dependabot-dark.png"><source media="(prefers-color-scheme: light)" srcset="pk
g/octicons/icons/dependabot-light.png"><img src="pkg/octicons/icons/dependabot-l
ight.png" width="20" height="20" alt="dependabot"></picture> | `dependabot` | De
pendabot tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/comment-discussion-dark.png"><source media="(prefers-color-scheme: light)" sr
cset="pkg/octicons/icons/comment-discussion-light.png"><img src="pkg/octicons/ic
ons/comment-discussion-light.png" width="20" height="20" alt="comment-discussion
"></picture> | `discussions` | GitHub Discussions related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/logo-gist-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg
/octicons/icons/logo-gist-light.png"><img src="pkg/octicons/icons/logo-gist-ligh
t.png" width="20" height="20" alt="logo-gist"></picture> | `gists` | GitHub Gist
 related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/git-branch-dark.png"><source media="(prefers-color-scheme: light)" srcset="pk
g/octicons/icons/git-branch-light.png"><img src="pkg/octicons/icons/git-branch-l
ight.png" width="20" height="20" alt="git-branch"></picture> | `git` | GitHub Gi
t API related tools for low-level Git operations |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/issue-opened-dark.png"><source media="(prefers-color-scheme: light)" srcset="
pkg/octicons/icons/issue-opened-light.png"><img src="pkg/octicons/icons/issue-op
ened-light.png" width="20" height="20" alt="issue-opened"></picture> | `issues`
| GitHub Issues related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/tag-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/octic
ons/icons/tag-light.png"><img src="pkg/octicons/icons/tag-light.png" width="20"
height="20" alt="tag"></picture> | `labels` | GitHub Labels related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/bell-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/octi
cons/icons/bell-light.png"><img src="pkg/octicons/icons/bell-light.png" width="2
0" height="20" alt="bell"></picture> | `notifications` | GitHub Notifications re
lated tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/organization-dark.png"><source media="(prefers-color-scheme: light)" srcset="
pkg/octicons/icons/organization-light.png"><img src="pkg/octicons/icons/organiza
tion-light.png" width="20" height="20" alt="organization"></picture> | `orgs` |
GitHub Organization related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/project-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/o
cticons/icons/project-light.png"><img src="pkg/octicons/icons/project-light.png"
 width="20" height="20" alt="project"></picture> | `projects` | GitHub Projects
related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/git-pull-request-dark.png"><source media="(prefers-color-scheme: light)" srcs
et="pkg/octicons/icons/git-pull-request-light.png"><img src="pkg/octicons/icons/
git-pull-request-light.png" width="20" height="20" alt="git-pull-request"></pict
ure> | `pull_requests` | GitHub Pull Request related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/repo-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/octi
cons/icons/repo-light.png"><img src="pkg/octicons/icons/repo-light.png" width="2
0" height="20" alt="repo"></picture> | `repos` | GitHub Repository related tools
 |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/shield-lock-dark.png"><source media="(prefers-color-scheme: light)" srcset="p
kg/octicons/icons/shield-lock-light.png"><img src="pkg/octicons/icons/shield-loc
k-light.png" width="20" height="20" alt="shield-lock"></picture> | `secret_prote
ction` | Secret protection related tools, such as GitHub Secret Scanning |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/shield-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/oc
ticons/icons/shield-light.png"><img src="pkg/octicons/icons/shield-light.png" wi
dth="20" height="20" alt="shield"></picture> | `security_advisories` | Security
advisories related tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/star-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/octi
cons/icons/star-light.png"><img src="pkg/octicons/icons/star-light.png" width="2
0" height="20" alt="star"></picture> | `stargazers` | GitHub Stargazers related
tools |
| <picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octicons/ico
ns/people-dark.png"><source media="(prefers-color-scheme: light)" srcset="pkg/oc
ticons/icons/people-light.png"><img src="pkg/octicons/icons/people-light.png" wi
dth="20" height="20" alt="people"></picture> | `users` | GitHub User related too
ls |
<!-- END AUTOMATED TOOLSETS -->

### Additional Toolsets in Remote GitHub MCP Server

| Toolset                 | Description
          |
| ----------------------- | ----------------------------------------------------
--------- |
| `copilot` | Copilot related tools (e.g. Copilot Coding Agent) |
| `copilot_spaces` | Copilot Spaces related tools |
| `github_support_docs_search` | Search docs to answer GitHub product and suppor
t questions |

## Tools

<!-- START AUTOMATED TOOLS -->
<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/workflow-dark.png"><source media="(prefers-color-scheme: light)" srcse
t="pkg/octicons/icons/workflow-light.png"><img src="pkg/octicons/icons/workflow-
light.png" width="20" height="20" alt="workflow"></picture> Actions</summary>

- **actions_get** - Get details of GitHub Actions resources (workflows, workflow
 runs, jobs, and artifacts)
  - **Required OAuth Scopes**: `repo`
  - `method`: The method to execute (string, required)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `resource_id`: The unique identifier of the resource. This will vary based o
n the "method" provided, so ensure you provide the correct ID:
    - Provide a workflow ID or workflow file name (e.g. ci.yaml) for 'get_workfl
ow' method.
    - Provide a workflow run ID for 'get_workflow_run', 'get_workflow_run_usage'
, and 'get_workflow_run_logs_url' methods.
    - Provide an artifact ID for 'download_workflow_run_artifact' method.
    - Provide a job ID for 'get_workflow_job' method.
     (string, required)

- **actions_list** - List GitHub Actions workflows in a repository
  - **Required OAuth Scopes**: `repo`
  - `method`: The action to perform (string, required)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (default: 1) (number, optional)
  - `per_page`: Results per page for pagination (default: 30, max: 100) (number,
 optional)
  - `repo`: Repository name (string, required)
  - `resource_id`: The unique identifier of the resource. This will vary based o
n the "method" provided, so ensure you provide the correct ID:
    - Do not provide any resource ID for 'list_workflows' method.
    - Provide a workflow ID or workflow file name (e.g. ci.yaml) for 'list_workf
low_runs' method, or omit to list all workflow runs in the repository.
    - Provide a workflow run ID for 'list_workflow_jobs' and 'list_workflow_run_
artifacts' methods.
     (string, optional)
  - `workflow_jobs_filter`: Filters for workflow jobs. **ONLY** used when method
 is 'list_workflow_jobs' (object, optional)
  - `workflow_runs_filter`: Filters for workflow runs. **ONLY** used when method
 is 'list_workflow_runs' (object, optional)

- **actions_run_trigger** - Trigger GitHub Actions workflow actions
  - **Required OAuth Scopes**: `repo`
  - `inputs`: Inputs the workflow accepts. Only used for 'run_workflow' method.
(object, optional)
  - `method`: The method to execute (string, required)
  - `owner`: Repository owner (string, required)
  - `ref`: The git reference for the workflow. The reference can be a branch or
tag name. Required for 'run_workflow' method. (string, optional)
  - `repo`: Repository name (string, required)
  - `run_id`: The ID of the workflow run. Required for all methods except 'run_w
orkflow'. (number, optional)
  - `workflow_id`: The workflow ID (numeric) or workflow file name (e.g., main.y
ml, ci.yaml). Required for 'run_workflow' method. (string, optional)

- **get_job_logs** - Get GitHub Actions workflow job logs
  - **Required OAuth Scopes**: `repo`
  - `failed_only`: When true, gets logs for all failed jobs in the workflow run
specified by run_id. Requires run_id to be provided. (boolean, optional)
  - `job_id`: The unique identifier of the workflow job. Required when getting l
ogs for a single job. (number, optional)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `return_content`: Returns actual log content instead of URLs (boolean, optio
nal)
  - `run_id`: The unique identifier of the workflow run. Required when failed_on
ly is true to get logs for all failed jobs in the run. (number, optional)
  - `tail_lines`: Number of lines to return from the end of the log (number, opt
ional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/code-square-dark.png"><source media="(prefers-color-scheme: light)" sr
cset="pkg/octicons/icons/code-square-light.png"><img src="pkg/octicons/icons/cod
e-square-light.png" width="20" height="20" alt="code-square"></picture> Code Qua
lity</summary>

- **get_code_quality_finding** - Get code quality finding
  - **Required OAuth Scopes**: `repo`
  - `findingNumber`: The number of the finding. (number, required)
  - `owner`: The owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/codescan-dark.png"><source media="(prefers-color-scheme: light)" srcse
t="pkg/octicons/icons/codescan-light.png"><img src="pkg/octicons/icons/codescan-
light.png" width="20" height="20" alt="codescan"></picture> Code Security</summa
ry>

- **get_code_scanning_alert** - Get code scanning alert
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `alertNumber`: The number of the alert. (number, required)
  - `owner`: The owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)

- **list_code_scanning_alerts** - List code scanning alerts
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `owner`: The owner of the repository. (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `ref`: The Git reference for the results you want to list. (string, optional
)
  - `repo`: The name of the repository. (string, required)
  - `severity`: Filter code scanning alerts by severity (string, optional)
  - `state`: Filter code scanning alerts by state. Defaults to open (string, opt
ional)
  - `tool_name`: The name of the tool used for code scanning. (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/person-dark.png"><source media="(prefers-color-scheme: light)" srcset=
"pkg/octicons/icons/person-light.png"><img src="pkg/octicons/icons/person-light.
png" width="20" height="20" alt="person"></picture> Context</summary>

- **get_me** - Get my user profile
  - No parameters required

- **get_team_members** - Get team members
  - **Required OAuth Scopes**: `read:org`
  - **Accepted OAuth Scopes**: `admin:org`, `read:org`, `write:org`
  - `org`: Organization login (owner) that contains the team. (string, required)
  - `team_slug`: Team slug (string, required)

- **get_teams** - Get teams
  - **Required OAuth Scopes**: `read:org`
  - **Accepted OAuth Scopes**: `admin:org`, `read:org`, `write:org`
  - `user`: Username to get teams for. If not provided, uses the authenticated u
ser. (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/copilot-dark.png"><source media="(prefers-color-scheme: light)" srcset
="pkg/octicons/icons/copilot-light.png"><img src="pkg/octicons/icons/copilot-lig
ht.png" width="20" height="20" alt="copilot"></picture> Copilot</summary>

- **assign_copilot_to_issue** - Assign Copilot to issue
  - **Required OAuth Scopes**: `repo`
  - `base_ref`: Git reference (e.g., branch) that the agent will start its work
from. If not specified, defaults to the repository's default branch (string, opt
ional)
  - `custom_instructions`: Optional custom instructions to guide the agent beyon
d the issue body. Use this to provide additional context, constraints, or guidan
ce that is not captured in the issue description (string, optional)
  - `issue_number`: Issue number (number, required)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **request_copilot_review** - Request Copilot review
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/dependabot-dark.png"><source media="(prefers-color-scheme: light)" src
set="pkg/octicons/icons/dependabot-light.png"><img src="pkg/octicons/icons/depen
dabot-light.png" width="20" height="20" alt="dependabot"></picture> Dependabot</
summary>

- **get_dependabot_alert** - Get dependabot alert
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `alertNumber`: The number of the alert. (number, required)
  - `owner`: The owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)

- **list_dependabot_alerts** - List dependabot alerts
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `after`: Cursor for pagination. Use the cursor from the previous response. (
string, optional)
  - `owner`: The owner of the repository. (string, required)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: The name of the repository. (string, required)
  - `severity`: Filter dependabot alerts by severity (string, optional)
  - `state`: Filter dependabot alerts by state. Defaults to open (string, option
al)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/comment-discussion-dark.png"><source media="(prefers-color-scheme: lig
ht)" srcset="pkg/octicons/icons/comment-discussion-light.png"><img src="pkg/octi
cons/icons/comment-discussion-light.png" width="20" height="20" alt="comment-dis
cussion"></picture> Discussions</summary>

- **discussion_comment_write** - Manage discussion comments
  - **Required OAuth Scopes**: `repo`
  - `body`: Comment content (required for 'add', 'reply', and 'update' methods)
(string, optional)
  - `commentNodeID`: The Node ID of the discussion comment (required for 'reply'
, 'update', 'delete', 'mark_answer', and 'unmark_answer' methods). For 'reply',
this is the top-level comment to reply to; GitHub Discussions only support one l
evel of nesting. (string, optional)
  - `discussionNumber`: Discussion number (required for 'add' and 'reply' method
s) (number, optional)
  - `method`: Write operation to perform on a discussion comment.
    Options are:
    - 'add' - adds a new top-level comment to a discussion.
    - 'reply' - replies to a top-level discussion comment (GitHub Discussions on
ly support one level of nesting).
    - 'update' - updates an existing discussion comment.
    - 'delete' - deletes a discussion comment.
    - 'mark_answer' - marks a discussion comment as the answer (Q&A only).
    - 'unmark_answer' - unmarks a discussion comment as the answer (Q&A only).
     (string, required)
  - `owner`: Repository owner (required for 'add' and 'reply' methods) (string,
optional)
  - `repo`: Repository name (required for 'add' and 'reply' methods) (string, op
tional)

- **get_discussion** - Get discussion
  - **Required OAuth Scopes**: `repo`
  - `discussionNumber`: Discussion Number (number, required)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **get_discussion_comments** - Get discussion comments
  - **Required OAuth Scopes**: `repo`
  - `after`: Cursor for pagination. Use the cursor from the previous response. (
string, optional)
  - `discussionNumber`: Discussion Number (number, required)
  - `includeReplies`: When true, each top-level comment will include its replies
 nested within it (up to 100 replies per comment, which is the GitHub API maximu
m). Defaults to false. (boolean, optional)
  - `owner`: Repository owner (string, required)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)

- **list_discussion_categories** - List discussion categories
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name. If not provided, discussion categories will be quer
ied at the organisation level. (string, optional)

- **list_discussions** - List discussions
  - **Required OAuth Scopes**: `repo`
  - `after`: Cursor for pagination. Use the cursor from the previous response. (
string, optional)
  - `category`: Optional filter by discussion category ID. If provided, only dis
cussions with this category are listed. (string, optional)
  - `direction`: Order direction. (string, optional)
  - `orderBy`: Order discussions by field. If provided, the 'direction' also nee
ds to be provided. (string, optional)
  - `owner`: Repository owner (string, required)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name. If not provided, discussions will be queried at the
 organisation level. (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/logo-gist-dark.png"><source media="(prefers-color-scheme: light)" srcs
et="pkg/octicons/icons/logo-gist-light.png"><img src="pkg/octicons/icons/logo-gi
st-light.png" width="20" height="20" alt="logo-gist"></picture> Gists</summary>

- **create_gist** - Create Gist
  - **Required OAuth Scopes**: `gist`
  - `content`: Content for simple single-file gist creation (string, required)
  - `description`: Description of the gist (string, optional)
  - `filename`: Filename for simple single-file gist creation (string, required)
  - `public`: Whether the gist is public (boolean, optional)

- **get_gist** - Get Gist Content
  - `gist_id`: The ID of the gist (string, required)

- **list_gists** - List Gists
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `since`: Only gists updated after this time (ISO 8601 timestamp) (string, op
tional)
  - `username`: GitHub username (omit for authenticated user's gists) (string, o
ptional)

- **update_gist** - Update Gist
  - **Required OAuth Scopes**: `gist`
  - `content`: Content for the file (string, required)
  - `description`: Updated description of the gist (string, optional)
  - `filename`: Filename to update or create (string, required)
  - `gist_id`: ID of the gist to update (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/git-branch-dark.png"><source media="(prefers-color-scheme: light)" src
set="pkg/octicons/icons/git-branch-light.png"><img src="pkg/octicons/icons/git-b
ranch-light.png" width="20" height="20" alt="git-branch"></picture> Git</summary
>

- **get_repository_tree** - Get repository tree
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (username or organization) (string, required)
  - `path_filter`: Optional path prefix to filter the tree results (e.g., 'src/'
 to only show files in the src directory) (string, optional)
  - `recursive`: Setting this parameter to true returns the objects or subtrees
referenced by the tree. Default is false (boolean, optional)
  - `repo`: Repository name (string, required)
  - `tree_sha`: The SHA1 value or ref (branch or tag) name of the tree. Defaults
 to the repository's default branch (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/issue-opened-dark.png"><source media="(prefers-color-scheme: light)" s
rcset="pkg/octicons/icons/issue-opened-light.png"><img src="pkg/octicons/icons/i
ssue-opened-light.png" width="20" height="20" alt="issue-opened"></picture> Issu
es</summary>

- **add_issue_comment** - Add comment to issue or pull request
  - **Required OAuth Scopes**: `repo`
  - `body`: Comment content. Required unless reaction is provided. (string, opti
onal)
  - `comment_id`: The numeric ID of the issue or pull request comment to react t
o. Use this for reactions to comments; omit it to react to the issue or pull req
uest itself. Cannot be combined with body. (number, optional)
  - `issue_number`: Issue or pull request number to comment on or react to. (num
ber, required)
  - `owner`: Repository owner (string, required)
  - `reaction`: Emoji reaction to add. Required unless body is provided. (string
, optional)
  - `repo`: Repository name (string, required)

- **get_label** - Get a specific label from a repository
  - **Required OAuth Scopes**: `repo`
  - `name`: Label name. (string, required)
  - `owner`: Repository owner (username or organization name) (string, required)
  - `repo`: Repository name (string, required)

- **issue_read** - Get issue details
  - **Required OAuth Scopes**: `repo`
  - `issue_number`: The number of the issue (number, required)
  - `method`: The read operation to perform on a single issue.
    Options are:
    1. get - Get details of a specific issue.
    2. get_comments - Get issue comments.
    3. get_sub_issues - Get sub-issues (children) of the issue.
    4. get_parent - Get the parent issue, if this issue is a sub-issue of anothe
r.
    5. get_labels - Get labels assigned to the issue.
     (string, required)
  - `owner`: The owner of the repository (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: The name of the repository (string, required)

- **issue_write** - Create or update issue/pull request
  - **Required OAuth Scopes**: `repo`
  - `assignees`: Usernames to assign to this issue (string[], optional)
  - `body`: Issue body content (string, optional)
  - `duplicate_of`: Issue number that this issue is a duplicate of. Only used wh
en state_reason is 'duplicate'. (number, optional)
  - `issue_fields`: Issue field values to set or clear. Each item requires 'fiel
d_name' and exactly one of 'value', 'field_option_name', or 'delete: true'. (obj
ect[], optional)
  - `issue_number`: Issue number to update (number, optional)
  - `labels`: Labels to apply to this issue (string[], optional)
  - `method`: Write operation to perform on a single issue.
    Options are:
    - 'create' - creates a new issue.
    - 'update' - updates an existing issue.
     (string, required)
  - `milestone`: Milestone number (number, optional)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `state`: New state (string, optional)
  - `state_reason`: Reason for the state change. Ignored unless state is changed
. (string, optional)
  - `title`: Issue title (string, optional)
  - `type`: Type of this issue. Only use if issue types are enabled for this rep
ository. Use list_issue_types tool to get valid type values for this repository
or its owner organization. If the repository doesn't support issue types, omit t
his parameter. (string, optional)

- **list_issue_fields** - List issue fields
  - **Required OAuth Scopes (any of)**: `repo`, `read:org`
  - **Accepted OAuth Scopes**: `admin:org`, `read:org`, `repo`, `write:org`
  - `owner`: The account owner of the repository or organization. The name is no
t case sensitive. (string, required)
  - `repo`: The name of the repository. When provided, returns fields for this s
pecific repository (inherited from its organization). When omitted, returns org-
level fields directly. (string, optional)

- **list_issue_types** - List available issue types
  - **Required OAuth Scopes (any of)**: `repo`, `read:org`
  - **Accepted OAuth Scopes**: `admin:org`, `read:org`, `repo`, `write:org`
  - `owner`: The account owner of the repository or organization. (string, requi
red)
  - `repo`: The name of the repository. When provided, returns issue types for t
his specific repository. When omitted, returns org-level issue types directly. (
string, optional)

- **list_issues** - List issues
  - **Required OAuth Scopes**: `repo`
  - `after`: Cursor for pagination. Use the cursor from the previous response. (
string, optional)
  - `direction`: Order direction. If provided, the 'orderBy' also needs to be pr
ovided. (string, optional)
  - `field_filters`: Filter by custom issue field values. Each entry takes a fie
ld_name and a value; the server looks up the field and coerces the value to its
type (single-select option name, text, number, or YYYY-MM-DD date). (object[], o
ptional)
  - `labels`: Filter by labels (string[], optional)
  - `orderBy`: Order issues by field. If provided, the 'direction' also needs to
 be provided. (string, optional)
  - `owner`: Repository owner (string, required)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)
  - `since`: Filter by date (ISO 8601 timestamp) (string, optional)
  - `state`: Filter by state, by default both open and closed issues are returne
d when not provided (string, optional)

- **search_issues** - Search issues
  - **Required OAuth Scopes**: `repo`
  - `order`: Sort order (string, optional)
  - `owner`: Optional repository owner. If provided with repo, only issues for t
his repository are listed. (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Search query using GitHub issues search syntax (string, required)
  - `repo`: Optional repository name. If provided with owner, only issues for th
is repository are listed. (string, optional)
  - `sort`: Sort field by number of matches of categories, defaults to best matc
h (string, optional)

- **sub_issue_write** - Change sub-issue
  - **Required OAuth Scopes**: `repo`
  - `after_id`: The ID of the sub-issue to be prioritized after (either after_id
 OR before_id should be specified) (number, optional)
  - `before_id`: The ID of the sub-issue to be prioritized before (either after_
id OR before_id should be specified) (number, optional)
  - `issue_number`: The number of the parent issue (number, required)
  - `method`: The action to perform on a single sub-issue
    Options are:
    - 'add' - add a sub-issue to a parent issue in a GitHub repository.
    - 'remove' - remove a sub-issue from a parent issue in a GitHub repository.
    - 'reprioritize' - change the order of sub-issues within a parent issue in a
 GitHub repository. Use either 'after_id' or 'before_id' to specify the new posi
tion.
                                 (string, required)
  - `owner`: Repository owner (string, required)
  - `replace_parent`: When true, replaces the sub-issue's current parent issue.
Use with 'add' method only. (boolean, optional)
  - `repo`: Repository name (string, required)
  - `sub_issue_id`: The ID of the sub-issue to add. ID is not the same as issue
number (number, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/tag-dark.png"><source media="(prefers-color-scheme: light)" srcset="pk
g/octicons/icons/tag-light.png"><img src="pkg/octicons/icons/tag-light.png" widt
h="20" height="20" alt="tag"></picture> Labels</summary>

- **get_label** - Get a specific label from a repository
  - **Required OAuth Scopes**: `repo`
  - `name`: Label name. (string, required)
  - `owner`: Repository owner (username or organization name) (string, required)
  - `repo`: Repository name (string, required)

- **label_write** - Write operations on repository labels
  - **Required OAuth Scopes**: `repo`
  - `color`: Label color as 6-character hex code without '#' prefix (e.g., 'f295
13'). Required for 'create', optional for 'update'. (string, optional)
  - `description`: Label description text. Optional for 'create' and 'update'. (
string, optional)
  - `method`: Operation to perform: 'create', 'update', or 'delete' (string, req
uired)
  - `name`: Label name - required for all operations (string, required)
  - `new_name`: New name for the label (used only with 'update' method to rename
) (string, optional)
  - `owner`: Repository owner (username or organization name) (string, required)
  - `repo`: Repository name (string, required)

- **list_label** - List labels from a repository
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (username or organization name) - required for all
 operations (string, required)
  - `repo`: Repository name - required for all operations (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/bell-dark.png"><source media="(prefers-color-scheme: light)" srcset="p
kg/octicons/icons/bell-light.png"><img src="pkg/octicons/icons/bell-light.png" w
idth="20" height="20" alt="bell"></picture> Notifications</summary>

- **dismiss_notification** - Dismiss notification
  - **Required OAuth Scopes**: `notifications`
  - `state`: The new state of the notification (read/done) (string, required)
  - `threadID`: The ID of the notification thread (string, required)

- **get_notification_details** - Get notification details
  - **Required OAuth Scopes**: `notifications`
  - `notificationID`: The ID of the notification (string, required)

- **list_notifications** - List notifications
  - **Required OAuth Scopes**: `notifications`
  - `before`: Only show notifications updated before the given time (ISO 8601 fo
rmat) (string, optional)
  - `filter`: Filter notifications to, use default unless specified. Read notifi
cations are ones that have already been acknowledged by the user. Participating
notifications are those that the user is directly involved in, such as issues or
 pull requests they have commented on or created. (string, optional)
  - `owner`: Optional repository owner. If provided with repo, only notification
s for this repository are listed. (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Optional repository name. If provided with owner, only notifications
 for this repository are listed. (string, optional)
  - `since`: Only show notifications updated after the given time (ISO 8601 form
at) (string, optional)

- **manage_notification_subscription** - Manage notification subscription
  - **Required OAuth Scopes**: `notifications`
  - `action`: Action to perform: ignore, watch, or delete the notification subsc
ription. (string, required)
  - `notificationID`: The ID of the notification thread. (string, required)

- **manage_repository_notification_subscription** - Manage repository notificati
on subscription
  - **Required OAuth Scopes**: `notifications`
  - `action`: Action to perform: ignore, watch, or delete the repository notific
ation subscription. (string, required)
  - `owner`: The account owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)

- **mark_all_notifications_read** - Mark all notifications as read
  - **Required OAuth Scopes**: `notifications`
  - `lastReadAt`: Describes the last point that notifications were checked (opti
onal). Default: Now (string, optional)
  - `owner`: Optional repository owner. If provided with repo, only notification
s for this repository are marked as read. (string, optional)
  - `repo`: Optional repository name. If provided with owner, only notifications
 for this repository are marked as read. (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/organization-dark.png"><source media="(prefers-color-scheme: light)" s
rcset="pkg/octicons/icons/organization-light.png"><img src="pkg/octicons/icons/o
rganization-light.png" width="20" height="20" alt="organization"></picture> Orga
nizations</summary>

- **search_orgs** - Search organizations
  - **Required OAuth Scopes**: `read:org`
  - **Accepted OAuth Scopes**: `admin:org`, `read:org`, `write:org`
  - `order`: Sort order (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Organization search query. Examples: 'microsoft', 'location:califor
nia', 'created:>=2025-01-01'. Search is automatically scoped to type:org. (strin
g, required)
  - `sort`: Sort field by category (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/project-dark.png"><source media="(prefers-color-scheme: light)" srcset
="pkg/octicons/icons/project-light.png"><img src="pkg/octicons/icons/project-lig
ht.png" width="20" height="20" alt="project"></picture> Projects</summary>

- **projects_get** - Get details of GitHub Projects resources
  - **Required OAuth Scopes**: `read:project`
  - **Accepted OAuth Scopes**: `project`, `read:project`
  - `field_id`: The field's ID. Required for 'get_project_field' method. (number
, optional)
  - `fields`: Specific list of field IDs to include in the response when getting
 a project item (e.g. ["102589", "985201", "169875"]). If not provided, only the
 title field is included. Only used for 'get_project_item' method. (string[], op
tional)
  - `item_id`: The item's ID. Required for 'get_project_item' method. (number, o
ptional)
  - `method`: The method to execute (string, required)
  - `owner`: The owner (user or organization login). The name is not case sensit
ive. (string, optional)
  - `owner_type`: Owner type (user or org). If not provided, will be automatical
ly detected. (string, optional)
  - `project_number`: The project's number. (number, optional)
  - `status_update_id`: The node ID of the project status update. Required for '
get_project_status_update' method. (string, optional)

- **projects_list** - List GitHub Projects resources
  - **Required OAuth Scopes**: `read:project`
  - **Accepted OAuth Scopes**: `project`, `read:project`
  - `after`: Forward pagination cursor from previous pageInfo.nextCursor. (strin
g, optional)
  - `before`: Backward pagination cursor from previous pageInfo.prevCursor (rare
). (string, optional)
  - `fields`: Field IDs to include when listing project items (e.g. ["102589", "
985201"]). CRITICAL: Always provide to get field values. Without this, only titl
es returned. Only used for 'list_project_items' method. (string[], optional)
  - `method`: The action to perform (string, required)
  - `owner`: The owner (user or organization login). The name is not case sensit
ive. (string, required)
  - `owner_type`: Owner type (user or org). If not provided, will automatically
try both. (string, optional)
  - `per_page`: Results per page (max 50) (number, optional)
  - `project_number`: The project's number. Required for 'list_project_fields',
'list_project_items', and 'list_project_status_updates' methods. (number, option
al)
  - `query`: Filter/query string. For list_projects: filter by title text and st
ate (e.g. "roadmap is:open"). For list_project_items: advanced filtering using G
itHub's project filtering syntax. (string, optional)

- **projects_write** - Manage GitHub Projects
  - **Required OAuth Scopes**: `project`
  - `body`: The body of the status update (markdown). Used for 'create_project_s
tatus_update' method. (string, optional)
  - `field_name`: The name of the iteration field (e.g. 'Sprint'). Required for
'create_iteration_field' method. (string, optional)
  - `issue_number`: The issue number (use when item_type is 'issue' for 'add_pro
ject_item' method). Provide either issue_number or pull_request_number. (number,
 optional)
  - `item_id`: The project item ID. Required for 'update_project_item' and 'dele
te_project_item' methods. (number, optional)
  - `item_owner`: The owner (user or organization) of the repository containing
the issue or pull request. Required for 'add_project_item' method. (string, opti
onal)
  - `item_repo`: The name of the repository containing the issue or pull request
. Required for 'add_project_item' method. (string, optional)
  - `item_type`: The item's type, either issue or pull_request. Required for 'ad
d_project_item' method. (string, optional)
  - `iteration_duration`: Duration in days for iterations of the field (e.g. 7 f
or weekly, 14 for bi-weekly). Required for 'create_iteration_field' method. (num
ber, optional)
  - `iterations`: Custom iterations for 'create_iteration_field' method. Only se
t this when you need iterations with varying durations, breaks between them, or
specific titles. Otherwise omit it: GitHub auto-creates three iterations of 'ite
ration_duration' days starting on 'start_date', which is the right choice for mo
st cases. (object[], optional)
  - `method`: The method to execute (string, required)
  - `owner`: The project owner (user or organization login). The name is not cas
e sensitive. (string, required)
  - `owner_type`: Owner type (user or org). Required for 'create_project' method
. If not provided for other methods, will be automatically detected. (string, op
tional)
  - `project_number`: The project's number. Required for all methods except 'cre
ate_project'. (number, optional)
  - `pull_request_number`: The pull request number (use when item_type is 'pull_
request' for 'add_project_item' method). Provide either issue_number or pull_req
uest_number. (number, optional)
  - `start_date`: Start date in YYYY-MM-DD format. Used for 'create_project_stat
us_update' and 'create_iteration_field' methods. (string, optional)
  - `status`: The status of the project. Used for 'create_project_status_update'
 method. (string, optional)
  - `target_date`: The target date of the status update in YYYY-MM-DD format. Us
ed for 'create_project_status_update' method. (string, optional)
  - `title`: The project title. Required for 'create_project' method. (string, o
ptional)
  - `updated_field`: Object consisting of the ID of the project field to update
and the new value for the field. To clear the field, set value to null. Example:
 {"id": 123456, "value": "New Value"}. Required for 'update_project_item' method
. (object, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/git-pull-request-dark.png"><source media="(prefers-color-scheme: light
)" srcset="pkg/octicons/icons/git-pull-request-light.png"><img src="pkg/octicons
/icons/git-pull-request-light.png" width="20" height="20" alt="git-pull-request"
></picture> Pull Requests</summary>

- **add_comment_to_pending_review** - Add review comment to the requester's late
st pending pull request review
  - **Required OAuth Scopes**: `repo`
  - `body`: The text of the review comment (string, required)
  - `line`: The line of the blob in the pull request diff that the comment appli
es to. For multi-line comments, the last line of the range (number, optional)
  - `owner`: Repository owner (string, required)
  - `path`: The relative path to the file that necessitates a comment (string, r
equired)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)
  - `side`: The side of the diff to comment on. LEFT indicates the previous stat
e, RIGHT indicates the new state (string, optional)
  - `startLine`: For multi-line comments, the first line of the range that the c
omment applies to (number, optional)
  - `startSide`: For multi-line comments, the starting side of the diff that the
 comment applies to. LEFT indicates the previous state, RIGHT indicates the new
state (string, optional)
  - `subjectType`: The level at which the comment is targeted (string, required)

- **add_reply_to_pull_request_comment** - Add reply to pull request comment
  - **Required OAuth Scopes**: `repo`
  - `body`: The text of the reply. Required unless reaction is provided. (string
, optional)
  - `commentId`: The numeric ID of the pull request review comment to reply or r
eact to. Use the number from a #discussion_r... anchor, not the GraphQL thread n
ode ID (PRRT_...). (number, required)
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number. Required when body is provided. (number,
optional)
  - `reaction`: Emoji reaction to add. Required unless body is provided. (string
, optional)
  - `repo`: Repository name (string, required)

- **create_pull_request** - Open new pull request
  - **Required OAuth Scopes**: `repo`
  - `base`: Branch to merge into (string, required)
  - `body`: PR description (string, optional)
  - `draft`: Create as draft PR (boolean, optional)
  - `head`: Branch containing changes (string, required)
  - `maintainer_can_modify`: Allow maintainer edits (boolean, optional)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `reviewers`: GitHub usernames or ORG/team-slug team reviewers to request rev
iews from (string[], optional)
  - `title`: PR title (string, required)

- **list_pull_requests** - List pull requests
  - **Required OAuth Scopes**: `repo`
  - `base`: Filter by base branch (string, optional)
  - `direction`: Sort direction (string, optional)
  - `head`: Filter by head user/org and branch (string, optional)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)
  - `sort`: Sort by (string, optional)
  - `state`: Filter by state (string, optional)

- **merge_pull_request** - Merge pull request
  - **Required OAuth Scopes**: `repo`
  - `commit_message`: Extra detail for merge commit (string, optional)
  - `commit_title`: Title for merge commit (string, optional)
  - `merge_method`: Merge method (string, optional)
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)

- **pull_request_read** - Get details for a single pull request
  - **Required OAuth Scopes**: `repo`
  - `after`: Cursor for pagination, used only by the get_review_comments method.
 Pass the endCursor from the previous page's PageInfo to fetch the next page. (s
tring, optional)
  - `method`: Action to specify what pull request data needs to be retrieved fro
m GitHub.
    Possible options:
     1. get - Get details of a specific pull request.
     2. get_diff - Get the diff of a pull request.
     3. get_status - Get combined commit status of a head commit in a pull reque
st.
     4. get_files - Get the list of files changed in a pull request. Use with pa
gination parameters to control the number of results returned.
     5. get_commits - Get the list of commits on a pull request. Use with pagina
tion parameters to control the number of results returned.
     6. get_review_comments - Get review threads on a pull request. Each thread
contains logically grouped review comments made on the same code location during
 pull request reviews. Returns threads with metadata (isResolved, isOutdated, is
Collapsed) and their associated comments. Use cursor-based pagination (perPage,
after) to control results.
     7. get_reviews - Get the reviews on a pull request. When asked for review c
omments, use get_review_comments method. Use with pagination parameters to contr
ol the number of results returned.
     8. get_comments - Get comments on a pull request. Use this if user doesn't
specifically want review comments. Use with pagination parameters to control the
 number of results returned.
     9. get_check_runs - Get check runs for the head commit of a pull request. C
heck runs are the individual CI/CD jobs and checks that run on the PR.
     (string, required)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)

- **pull_request_review_write** - Write operations (create, submit, delete) on p
ull request reviews
  - **Required OAuth Scopes**: `repo`
  - `body`: Review comment text (string, optional)
  - `commitID`: SHA of commit to review (string, optional)
  - `event`: Review action to perform. (string, optional)
  - `method`: The write operation to perform on pull request review. (string, re
quired)
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)
  - `threadId`: The node ID of the review thread (e.g., PRRT_kwDOxxx). Required
for resolve_thread and unresolve_thread methods. Get thread IDs from pull_reques
t_read with method get_review_comments. (string, optional)

- **search_pull_requests** - Search pull requests
  - **Required OAuth Scopes**: `repo`
  - `order`: Sort order (string, optional)
  - `owner`: Optional repository owner. If provided with repo, only pull request
s for this repository are listed. (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Search query using GitHub pull request search syntax (string, requi
red)
  - `repo`: Optional repository name. If provided with owner, only pull requests
 for this repository are listed. (string, optional)
  - `sort`: Sort field by number of matches of categories, defaults to best matc
h (string, optional)

- **update_pull_request** - Edit pull request
  - **Required OAuth Scopes**: `repo`
  - `base`: New base branch name (string, optional)
  - `body`: New description (string, optional)
  - `draft`: Mark pull request as draft (true) or ready for review (false) (bool
ean, optional)
  - `maintainer_can_modify`: Allow maintainer edits (boolean, optional)
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number to update (number, required)
  - `repo`: Repository name (string, required)
  - `reviewers`: GitHub usernames or ORG/team-slug team reviewers to request rev
iews from (string[], optional)
  - `state`: New state (string, optional)
  - `title`: New title (string, optional)

- **update_pull_request_branch** - Update pull request branch
  - **Required OAuth Scopes**: `repo`
  - `expectedHeadSha`: The expected SHA of the pull request's HEAD ref (string,
optional)
  - `owner`: Repository owner (string, required)
  - `pullNumber`: Pull request number (number, required)
  - `repo`: Repository name (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/repo-dark.png"><source media="(prefers-color-scheme: light)" srcset="p
kg/octicons/icons/repo-light.png"><img src="pkg/octicons/icons/repo-light.png" w
idth="20" height="20" alt="repo"></picture> Repositories</summary>

- **create_branch** - Create branch
  - **Required OAuth Scopes**: `repo`
  - `branch`: Name for new branch (string, required)
  - `from_branch`: Source branch (defaults to repo default) (string, optional)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **create_or_update_file** - Create or update file
  - **Required OAuth Scopes**: `repo`
  - `branch`: Branch to create/update the file in (string, required)
  - `content`: Content of the file (string, required)
  - `message`: Commit message (string, required)
  - `owner`: Repository owner (username or organization) (string, required)
  - `path`: Path where to create/update the file (string, required)
  - `repo`: Repository name (string, required)
  - `sha`: The blob SHA of the file being replaced. Required if the file already
 exists. (string, optional)

- **create_repository** - Create repository
  - **Required OAuth Scopes**: `repo`
  - `autoInit`: Initialize with README (boolean, optional)
  - `description`: Repository description (string, optional)
  - `name`: Repository name (string, required)
  - `organization`: Organization to create the repository in (omit to create in
your personal account) (string, optional)
  - `private`: Whether the repository should be private. Defaults to true (priva
te) when omitted. (boolean, optional)

- **delete_file** - Delete file
  - **Required OAuth Scopes**: `repo`
  - `branch`: Branch to delete the file from (string, required)
  - `message`: Commit message (string, required)
  - `owner`: Repository owner (username or organization) (string, required)
  - `path`: Path to the file to delete (string, required)
  - `repo`: Repository name (string, required)

- **fork_repository** - Fork repository
  - **Required OAuth Scopes**: `repo`
  - `organization`: Organization to fork to (string, optional)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **get_commit** - Get commit details
  - **Required OAuth Scopes**: `repo`
  - `detail`: Level of detail to include for changed files. "none" omits stats a
nd files entirely. "stats" (default) includes per-file metadata: filename, statu
s, and lines-of-code counts (additions, deletions, changes), with no patch conte
nt. "full_patch" additionally includes the unified diff content for each file an
d can be very large. (string, optional)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)
  - `sha`: Commit SHA, branch name, or tag name (string, required)

- **get_file_contents** - Get file or directory contents
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (username or organization) (string, required)
  - `path`: Path to file/directory (string, optional)
  - `ref`: Accepts optional git refs such as `refs/tags/{tag}`, `refs/heads/{bra
nch}` or `refs/pull/{pr_number}/head` (string, optional)
  - `repo`: Repository name (string, required)
  - `sha`: Accepts optional commit SHA. If specified, it will be used instead of
 ref (string, optional)

- **get_latest_release** - Get latest release
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **get_release_by_tag** - Get a release by tag name
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `tag`: Tag name (e.g., 'v1.0.0') (string, required)

- **get_tag** - Get tag details
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)
  - `tag`: Tag name (string, required)

- **list_branches** - List branches
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)

- **list_commits** - List commits
  - **Required OAuth Scopes**: `repo`
  - `author`: Author username or email address to filter commits by (string, opt
ional)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `path`: Only commits containing this file path will be returned (string, opt
ional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)
  - `sha`: Commit SHA, branch or tag name to list commits of. If not provided, u
ses the default branch of the repository. If a commit SHA is provided, will list
 commits up to that SHA. (string, optional)
  - `since`: Only commits after this date will be returned (ISO 8601 format: YYY
Y-MM-DDTHH:MM:SSZ or YYYY-MM-DD) (string, optional)
  - `until`: Only commits before this date will be returned (ISO 8601 format: YY
YY-MM-DDTHH:MM:SSZ or YYYY-MM-DD) (string, optional)

- **list_releases** - List releases
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)

- **list_repository_collaborators** - List repository collaborators
  - **Required OAuth Scopes**: `repo`
  - `affiliation`: Filter by affiliation. Can be one of: 'outside' (outside coll
aborators), 'direct' (all with permissions regardless of org membership), 'all'
(all collaborators). Default: 'all' (string, optional)
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (default 1, min 1) (number, optional)
  - `perPage`: Results per page for pagination (default 30, min 1, max 100) (num
ber, optional)
  - `repo`: Repository name (string, required)

- **list_tags** - List tags
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: Repository name (string, required)

- **push_files** - Push files to repository
  - **Required OAuth Scopes**: `repo`
  - `branch`: Branch to push to (string, required)
  - `files`: Array of file objects to push, each object with path (string) and c
ontent (string) (object[], required)
  - `message`: Commit message (string, required)
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **search_code** - Search code
  - **Required OAuth Scopes**: `repo`
  - `order`: Sort order for results (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Search query (GitHub code search REST). Implicit AND between terms;
 supports `OR`, `NOT`, and `"quoted phrase"` for exact match. Qualifiers: `repo:
owner/repo`, `org:`, `user:`, `language:`, `path:dir` (prefix match), `filename:
exact.ext`, `extension:`, `in:file`, `in:path`, `size:`, `is:archived`, `is:fork
`. Max 256 chars. Examples: `WithContext language:go org:github`; `"package main
" repo:o/r`; `func extension:go path:cmd repo:o/r`; `NOT TODO language:go repo:o
/r`. (string, required)
  - `sort`: Sort field ('indexed' only) (string, optional)

- **search_commits** - Search commits
  - **Required OAuth Scopes**: `repo`
  - `order`: Sort order (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Commit search query (GitHub commit search REST). Searches commit me
ssages on the default branch only. Scope the search with `repo:owner/repo`, `org
:`, or `user:` (queries without a scope qualifier match across all of GitHub and
 are usually not what you want). Other qualifiers: `author:`, `committer:`, `aut
hor-name:`, `committer-name:`, `author-email:`, `committer-email:`, `author-date
:`, `committer-date:` (supports `>`, `<`, `>=`, `<=`, and `YYYY-MM-DD..YYYY-MM-D
D` ranges), `merge:true|false`, `hash:`, `tree:`, `parent:`, `is:public`. Exampl
es: `repo:owner/repo fix panic`; `org:github author:defunkt committer-date:>=202
4-01-01`; `"refactor cache" repo:o/r`; `hash:abc1234 repo:o/r`. (string, require
d)
  - `sort`: Sort by author or committer date (defaults to best match) (string, o
ptional)

- **search_repositories** - Search repositories
  - **Required OAuth Scopes**: `repo`
  - `minimal_output`: Return minimal repository information (default: true). Whe
n false, returns full GitHub API repository objects. (boolean, optional)
  - `order`: Sort order (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: Repository search query. Examples: 'machine learning in:name stars:
>1000 language:python', 'topic:react', 'user:facebook'. Supports advanced search
 syntax for precise filtering. (string, required)
  - `sort`: Sort repositories by field, defaults to best match (string, optional
)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/shield-lock-dark.png"><source media="(prefers-color-scheme: light)" sr
cset="pkg/octicons/icons/shield-lock-light.png"><img src="pkg/octicons/icons/shi
eld-lock-light.png" width="20" height="20" alt="shield-lock"></picture> Secret P
rotection</summary>

- **get_secret_scanning_alert** - Get secret scanning alert
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `alertNumber`: The number of the alert. (number, required)
  - `owner`: The owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)

- **list_secret_scanning_alerts** - List secret scanning alerts
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `owner`: The owner of the repository. (string, required)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `repo`: The name of the repository. (string, required)
  - `resolution`: Filter by resolution (string, optional)
  - `secret_type`: A comma-separated list of secret types to return. All default
 secret patterns are returned. To return generic patterns, pass the token name(s
) in the parameter. (string, optional)
  - `state`: Filter by state (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/shield-dark.png"><source media="(prefers-color-scheme: light)" srcset=
"pkg/octicons/icons/shield-light.png"><img src="pkg/octicons/icons/shield-light.
png" width="20" height="20" alt="shield"></picture> Security Advisories</summary
>

- **get_global_security_advisory** - Get a global security advisory
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `ghsaId`: GitHub Security Advisory ID (format: GHSA-xxxx-xxxx-xxxx). (string
, required)

- **list_global_security_advisories** - List global security advisories
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `affects`: Filter advisories by affected package or version (e.g. "package1,
package2@1.0.0"). (string, optional)
  - `cveId`: Filter by CVE ID. (string, optional)
  - `cwes`: Filter by Common Weakness Enumeration IDs (e.g. ["79", "284", "22"])
. (string[], optional)
  - `ecosystem`: Filter by package ecosystem. (string, optional)
  - `ghsaId`: Filter by GitHub Security Advisory ID (format: GHSA-xxxx-xxxx-xxxx
). (string, optional)
  - `isWithdrawn`: Whether to only return withdrawn advisories. (boolean, option
al)
  - `modified`: Filter by publish or update date or date range (ISO 8601 date or
 range). (string, optional)
  - `published`: Filter by publish date or date range (ISO 8601 date or range).
(string, optional)
  - `severity`: Filter by severity. (string, optional)
  - `type`: Advisory type. (string, optional)
  - `updated`: Filter by update date or date range (ISO 8601 date or range). (st
ring, optional)

- **list_org_repository_security_advisories** - List org repository security adv
isories
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `direction`: Sort direction. (string, optional)
  - `org`: The organization login. (string, required)
  - `sort`: Sort field. (string, optional)
  - `state`: Filter by advisory state. (string, optional)

- **list_repository_security_advisories** - List repository security advisories
  - **Required OAuth Scopes**: `security_events`
  - **Accepted OAuth Scopes**: `repo`, `security_events`
  - `direction`: Sort direction. (string, optional)
  - `owner`: The owner of the repository. (string, required)
  - `repo`: The name of the repository. (string, required)
  - `sort`: Sort field. (string, optional)
  - `state`: Filter by advisory state. (string, optional)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/star-dark.png"><source media="(prefers-color-scheme: light)" srcset="p
kg/octicons/icons/star-light.png"><img src="pkg/octicons/icons/star-light.png" w
idth="20" height="20" alt="star"></picture> Stargazers</summary>

- **list_starred_repositories** - List starred repositories
  - **Required OAuth Scopes**: `repo`
  - `direction`: The direction to sort the results by. (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `sort`: How to sort the results. Can be either 'created' (when the repositor
y was starred) or 'updated' (when the repository was last pushed to). (string, o
ptional)
  - `username`: Username to list starred repositories for. Defaults to the authe
nticated user. (string, optional)

- **star_repository** - Star repository
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

- **unstar_repository** - Unstar repository
  - **Required OAuth Scopes**: `repo`
  - `owner`: Repository owner (string, required)
  - `repo`: Repository name (string, required)

</details>

<details>

<summary><picture><source media="(prefers-color-scheme: dark)" srcset="pkg/octic
ons/icons/people-dark.png"><source media="(prefers-color-scheme: light)" srcset=
"pkg/octicons/icons/people-light.png"><img src="pkg/octicons/icons/people-light.
png" width="20" height="20" alt="people"></picture> Users</summary>

- **search_users** - Search users
  - **Required OAuth Scopes**: `repo`
  - `order`: Sort order (string, optional)
  - `page`: Page number for pagination (min 1) (number, optional)
  - `perPage`: Results per page for pagination (min 1, max 100) (number, optiona
l)
  - `query`: User search query. Examples: 'john smith', 'location:seattle', 'fol
lowers:>100'. Search is automatically scoped to type:user. (string, required)
  - `sort`: Sort users by number of followers or repositories, or when the perso
n joined GitHub. (string, optional)

</details>
<!-- END AUTOMATED TOOLS -->

### Additional Tools in Remote GitHub MCP Server

<details>

<summary>Copilot</summary>

- **create_pull_request_with_copilot** - Perform task with GitHub Copilot coding
 agent
  - `owner`: Repository owner. You can guess the owner, but confirm it with the
user before proceeding. (string, required)
  - `repo`: Repository name. You can guess the repository name, but confirm it w
ith the user before proceeding. (string, required)
  - `problem_statement`: Detailed description of the task to be performed (e.g.,
 'Implement a feature that does X', 'Fix bug Y', etc.) (string, required)
  - `title`: Title for the pull request that will be created (string, required)
  - `base_ref`: Git reference (e.g., branch) that the agent will start its work
from. If not specified, defaults to the repository's default branch (string, opt
ional)

</details>

<details>

<summary>Copilot Spaces</summary>

- **Authentication note**
  - Fine-grained PATs are not hidden by classic PAT scope filtering, so these to
ols may still appear even when the token cannot use them.
  - For org-owned spaces, fine-grained PATs must be installed on the owning orga
nization and include `organization_copilot_spaces: read`.
  - If an org-owned space contains repository-backed resources, the token must a
lso have access to every referenced repository or the space may be treated as no
t found.

- **get_copilot_space** - Get Copilot Space
  - `owner`: The owner of the space. (string, required)
  - `name`: The name of the space. (string, required)

- **list_copilot_spaces** - List Copilot Spaces

</details>

<details>

<summary>GitHub Support Docs Search</summary>

- **github_support_docs_search** - Retrieve documentation relevant to answer Git
Hub product and support questions. Support topics include: GitHub Actions Workfl
ows, Authentication, GitHub Support Inquiries, Pull Request Practices, Repositor
y Maintenance, GitHub Pages, GitHub Packages, GitHub Discussions, Copilot Spaces
  - `query`: Input from the user about the question they need answered. This is
the latest raw unedited user message. You should ALWAYS leave the user message a
s it is, you should never modify it. (string, required)

</details>

## Read-Only Mode

To run the server in read-only mode, you can use the `--read-only` flag. This wi
ll only offer read-only tools, preventing any modifications to repositories, iss
ues, pull requests, etc.

```bash
./github-mcp-server --read-only
```

When using Docker, you can pass the read-only mode as an environment variable:

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_READ_ONLY=1 \
  ghcr.io/github/github-mcp-server
```

## Lockdown Mode

Lockdown mode limits the content that the server will surface from public reposi
tories. When enabled, the server checks whether the author of each item has push
 access to the repository. Private repositories are unaffected, and collaborator
s keep full access to their own content.

```bash
./github-mcp-server --lockdown-mode
```

When running with Docker, set the corresponding environment variable:

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<your-token> \
  -e GITHUB_LOCKDOWN_MODE=1 \
  ghcr.io/github/github-mcp-server
```

The behavior of lockdown mode depends on the tool invoked.

Following tools will return an error when the author lacks the push access:

- `issue_read:get`
- `pull_request_read:get`

Following tools will filter out content from users lacking the push access:

- `issue_read:get_comments`
- `issue_read:get_sub_issues`
- `pull_request_read:get_comments`
- `pull_request_read:get_review_comments`
- `pull_request_read:get_reviews`

## i18n / Overriding Descriptions

The descriptions of the tools can be overridden by creating a
`github-mcp-server-config.json` file in the same directory as the binary.

The file should contain a JSON object with the tool names as keys and the new
descriptions as values. For example:

```json
{
  "TOOL_ADD_ISSUE_COMMENT_DESCRIPTION": "an alternative description",
  "TOOL_CREATE_BRANCH_DESCRIPTION": "Create a new branch in a GitHub repository"
}
```

You can create an export of the current translations by running the binary with
the `--export-translations` flag.

This flag will preserve any translations/overrides you have made, while adding
any new translations that have been added to the binary since the last time you
exported.

```sh
./github-mcp-server --export-translations
cat github-mcp-server-config.json
```

You can also use ENV vars to override the descriptions. The environment
variable names are the same as the keys in the JSON file, prefixed with
`GITHUB_MCP_` and all uppercase.

For example, to override the `TOOL_ADD_ISSUE_COMMENT_DESCRIPTION` tool, you can
set the following environment variable:

```sh
export GITHUB_MCP_TOOL_ADD_ISSUE_COMMENT_DESCRIPTION="an alternative description
"
```

### Overriding Server Name and Title

The same override mechanism can be used to customize the MCP server's `name` and
`title` fields in the initialization response. This is useful when running
multiple GitHub MCP Server instances (e.g., one for github.com and one for
GitHub Enterprise Server) so that agents can distinguish between them.

| Key | Environment Variable | Default |
|-----|---------------------|---------|
| `SERVER_NAME` | `GITHUB_MCP_SERVER_NAME` | `github-mcp-server` |
| `SERVER_TITLE` | `GITHUB_MCP_SERVER_TITLE` | `GitHub MCP Server` |

For example, to configure a server instance for GitHub Enterprise Server:

```json
{
  "SERVER_NAME": "ghes-mcp-server",
  "SERVER_TITLE": "GHES MCP Server"
}
```

Or using environment variables:

```sh
export GITHUB_MCP_SERVER_NAME="ghes-mcp-server"
export GITHUB_MCP_SERVER_TITLE="GHES MCP Server"
```

## Library Usage

The exported Go API of this module should currently be considered unstable, and
subject to breaking changes. In the future, we may offer stability; please file
an issue if there is a use case where this would be valuable.

## License

This project is licensed under the terms of the MIT open source license. Please
refer to [MIT](./LICENSE) for the full terms.

