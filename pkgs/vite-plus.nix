# TODO: 公式の nixpkgs 対応(NixOS/nixpkgs#533925)が merge されたら
# pkgs.vite-plus に乗り換えてこのファイルと nvfetcher エントリを削除する
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
