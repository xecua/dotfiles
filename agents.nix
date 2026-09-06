{
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  chrome-devtools-mcp = inputs.mcp-servers-nix.packages.${system}.chrome-devtools-mcp;
  playwright-cli = pkgs.callPackage ./pkgs/playwright-cli.nix { };

  githubMcpUrl = "https://api.githubcopilot.com/mcp/";
  githubMcpHeaders = pkgs.writeShellApplication {
    name = "github-mcp-headers";
    runtimeInputs = [
      pkgs.gh
      pkgs.jq
    ];
    text = ''
      # Claude Code はヘルパに環境変数を渡さない (HOME と PATH だけ) ので、
      # GH_TOKEN 環境変数ではなく `gh auth login` で gh に保存した資格情報が必要
      if ! token=$(gh auth token 2>/dev/null); then
        echo "github-mcp-headers: gh is not logged in; run 'gh auth login' first" >&2
        exit 1
      fi
      jq -nc --arg t "$token" '{ Authorization: ("Bearer " + $t) }'
    '';
  };
in
{
  agents = {
    enable = true;

    marketplace = {
      name = "xecua";
      owner = {
        name = "xecua";
        email = "contact@caffeine.page";
      };
    };

    skills = {
      id3-tag-editor = ./skills/id3-tag-editor;
      sanitize-artifacts = ./skills/sanitize-artifacts;
      file-search = "${inputs.file-search-skill}/skills/file-search";
      conventional-commit = "${inputs.awesome-copilot}/skills/conventional-commit";
    };

    plugins.browser = {
      description = "Browser automation via chrome-devtools-mcp (auto-connect to a running Chrome)";
      mcpServers.chrome-devtools = {
        command = lib.getExe chrome-devtools-mcp;
        args = [ "--auto-connect" ];
      };
    };

    # claude-code
    plugins.github = {
      description = "GitHub remote MCP server (token from gh auth token)";
      hosts = [ "claude-code" ];
      mcpServers.github = {
        type = "http";
        url = githubMcpUrl;
        headersHelper = lib.getExe githubMcpHeaders;
      };
    };
    # codex
    codex.settings.mcp_servers.github = {
      url = githubMcpUrl;
      http_headers_helper = lib.getExe githubMcpHeaders;
    };

    # サブコマンドで ~/.agents/skills に skill を置く CLI: activation で毎回実行して更新
    toolSkills = {
      playwright-cli = {
        package = playwright-cli;
        installCommand = "${lib.getExe playwright-cli} install --skills agents --global";
      };
      android-cli = {
        package = pkgsUnstable.android-cli;
        # `android init` は ~/.agents/skills があればそこに android-cli skill を書く
        installCommand = "${lib.getExe' pkgsUnstable.android-cli "android"} init";
      };
    };

    # Claude Code の settings.json に部分マージする断片。
    # JSON のまま置いておくとエディタで $schema 検証が効くのでファイルから読む
    claude-code.settings = builtins.fromJSON (builtins.readFile ./claude/settings.json);
  };

  # 静的な部分は programs.claude-code に任せる
  programs.claude-code.hooksDir = ./claude/hooks;
}
