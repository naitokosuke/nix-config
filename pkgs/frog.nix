{
  lib,
  stdenvNoCC,
  sources,
}:

stdenvNoCC.mkDerivation {
  pname = "frog";
  version = sources.frog-darwin-arm64.version;
  src = sources.frog-darwin-arm64.src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -d $out/bin
    gunzip -c $src > $out/bin/frog
    chmod 755 $out/bin/frog
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/frog --version > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Automated friction logging for agents";
    homepage = "https://frog.fm";
    changelog = "https://github.com/wevm/frog/releases/tag/frog@${sources.frog-darwin-arm64.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "frog";
    platforms = [ "aarch64-darwin" ];
  };
}
