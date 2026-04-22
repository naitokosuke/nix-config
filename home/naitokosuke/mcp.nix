# MCP (Model Context Protocol) server configuration
#
# Uses natsukium/mcp-servers-nix (via home-manager sharedModules) as the
# central registry, and lets programs.claude-code consume servers declaratively.
#
# https://github.com/natsukium/mcp-servers-nix
{ ... }:

{
  mcp-servers.settings.servers = {
    # Chrome DevTools MCP — not covered by mcp-servers-nix's built-in modules,
    # declared via the freeform `settings.servers` escape hatch.
    # https://github.com/ChromeDevTools/chrome-devtools-mcp
    chrome-devtools = {
      command = "npx";
      args = [
        "-y"
        "chrome-devtools-mcp@latest"
      ];
    };
  };

  programs.mcp.enable = true;

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
