# SSH client configuration
#
# Private or machine-local host definitions (e.g. work servers) should not
# live in this repository; put them in ~/.ssh/config.d/ instead, which is
# pulled in via the Include directive below.
{
  programs.ssh = {
    enable = true;

    # Don't emit home-manager's implicit "*" defaults; write only the
    # settings declared below
    enableDefaultConfig = false;

    # Untracked host definitions (work servers etc.)
    includes = [ "config.d/*" ];

    settings."github.com" = {
      AddKeysToAgent = true;
      # macOS: remember the key passphrase in Keychain
      UseKeychain = true;
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
    };
  };
}
