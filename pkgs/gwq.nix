{
  lib,
  stdenvNoCC,
  versionCheckHook,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "gwq";
  version = lib.removePrefix "v" sources.gwq-darwin-arm64.version;
  src = sources.gwq-darwin-arm64.src;

  # The tarball has no top-level directory — the `gwq` binary sits at the root.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 gwq $out/bin/gwq
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Git worktree manager with fuzzy finder, designed as the worktree counterpart to ghq";
    homepage = "https://github.com/d-kuro/gwq";
    changelog = "https://github.com/d-kuro/gwq/releases/tag/${sources.gwq-darwin-arm64.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "gwq";
    platforms = [ "aarch64-darwin" ];
  };
}
