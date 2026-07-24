# TODO: Once official nixpkgs support (NixOS/nixpkgs#533925) is merged,
# switch to pkgs.vite-plus and delete this file and the nvfetcher entry.
{
  lib,
  stdenvNoCC,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "vite-plus";
  version = lib.removePrefix "v" sources.vite-plus-darwin-arm64.version;
  src = sources.vite-plus-darwin-arm64.src;

  # The tarball has no top-level directory — the `vp` binary sits at the root.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 vp $out/bin/vp
    # Provide the standalone aliases the official installer creates via
    # `vp env setup`: vp is a multi-call binary dispatching on argv[0]
    # (vpr -> `vp run`, vpx -> `vp dlx`). The node/npm/npx/corepack shims
    # it also creates are deliberately omitted — they belong to the
    # opt-out-able Node version manager and would conflict with Nix-managed Node.
    ln -s $out/bin/vp $out/bin/vpr
    ln -s $out/bin/vp $out/bin/vpx
    runHook postInstall
  '';

  meta = {
    description = "Unified toolchain for JavaScript";
    homepage = "https://viteplus.dev";
    changelog = "https://github.com/voidzero-dev/vite-plus/releases/tag/${sources.vite-plus-darwin-arm64.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "vp";
    platforms = [ "aarch64-darwin" ];
  };
}
