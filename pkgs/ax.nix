{
  lib,
  stdenvNoCC,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "ax";
  version = lib.removePrefix "v" sources.ax-darwin-arm64.version;
  src = sources.ax-darwin-arm64.src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/ax
    runHook postInstall
  '';

  meta = {
    description = "The AI-era curl";
    homepage = "https://github.com/yusukebe/ax";
    changelog = "https://github.com/yusukebe/ax/releases/tag/${sources.ax-darwin-arm64.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ax";
    platforms = [ "aarch64-darwin" ];
  };
}
