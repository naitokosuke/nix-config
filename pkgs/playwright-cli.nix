# TODO: Once official nixpkgs support (NixOS/nixpkgs#490230) is merged,
# switch to pkgs.playwright-cli and delete this file and the nvfetcher entry.
#
# Unlike the other packages here, this is a source build: @playwright/cli is
# distributed only on npm, with no prebuilt release binaries.
{
  lib,
  buildNpmPackage,
  sources,
}:

buildNpmPackage {
  pname = "playwright-cli";
  version = lib.removePrefix "v" sources.playwright-cli.version;
  src = sources.playwright-cli.src;

  # Not tracked by nvfetcher — update by hand when the version bumps;
  # the build fails loudly on a stale hash.
  npmDepsHash = "sha256-u44jWprmr3RdzB3aDL3K0ShT5lLxr175z3C8pN43YFA=";

  dontNpmBuild = true;

  # Browsers stay runtime-managed in Playwright's own cache. Pinning
  # nixpkgs' playwright-driver.browsers would mismatch the vendored
  # Playwright (1.62.0-alpha vs nixpkgs' 1.61.x).

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/playwright-cli --version > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Playwright CLI for browser automation";
    homepage = "https://github.com/microsoft/playwright-cli";
    changelog = "https://github.com/microsoft/playwright-cli/releases/tag/${sources.playwright-cli.version}";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
  };
}
