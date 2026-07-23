{
  lib,
  stdenvNoCC,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "octorus";
  version = sources.octorus-darwin-arm64.version;
  src = sources.octorus-darwin-arm64.src;

  installPhase = ''
    runHook preInstall
    install -Dm755 or $out/bin/or
    runHook postInstall
  '';

  meta = {
    description = "AI-powered PR review tool";
    homepage = "https://github.com/ushironoko/octorus";
    changelog = "https://github.com/ushironoko/octorus/releases/tag/v${sources.octorus-darwin-arm64.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "or";
    platforms = [ "aarch64-darwin" ];
  };
}
