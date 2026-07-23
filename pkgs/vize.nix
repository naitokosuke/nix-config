{
  lib,
  stdenvNoCC,
  versionCheckHook,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "vize";
  version = lib.removePrefix "v" sources.vize-darwin-arm64.version;
  src = sources.vize-darwin-arm64.src;

  # The tarball has no top-level directory — the `vize` binary sits at the root.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 vize $out/bin/vize
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "High-performance Vue.js toolchain in Rust";
    homepage = "https://vizejs.dev";
    changelog = "https://github.com/ubugeeei-prod/vize/releases/tag/${sources.vize-darwin-arm64.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "vize";
    platforms = [ "aarch64-darwin" ];
  };
}
