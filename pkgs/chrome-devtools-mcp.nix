# MCP server exposing Chrome DevTools to coding agents.
# The published npm tarball bundles all dependencies and ships prebuilt JS
# (dependencies = {}), so it is unpacked as-is and wrapped with node — the
# same "official artifact" approach as the binary packages here.
# Consumed by home/mcp.nix via its store path.
{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  nodejs,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "chrome-devtools-mcp";
  inherit (sources.chrome-devtools-mcp) version;
  src = sources.chrome-devtools-mcp.src;

  # npm tarballs unpack to a top-level "package" directory
  sourceRoot = "package";

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/chrome-devtools-mcp
    cp -r . $out/lib/chrome-devtools-mcp/
    makeWrapper ${lib.getExe nodejs} $out/bin/chrome-devtools-mcp \
      --add-flags $out/lib/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    version_output=$($out/bin/chrome-devtools-mcp --version)
    [ "$version_output" = "${sources.chrome-devtools-mcp.version}" ]
    runHook postInstallCheck
  '';

  meta = {
    description = "Chrome DevTools MCP server for browser automation and debugging";
    homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
    changelog = "https://github.com/ChromeDevTools/chrome-devtools-mcp/releases/tag/chrome-devtools-mcp-v${sources.chrome-devtools-mcp.version}";
    license = lib.licenses.asl20;
    mainProgram = "chrome-devtools-mcp";
    platforms = lib.platforms.all;
  };
}
