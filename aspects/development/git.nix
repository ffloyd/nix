{config, ...}: let
  inherit (config.my.consts) fullName;
in {
  my.aspects.development = {
    features = [
      ["common" "Git, SSH, and commit signing setup"]
    ];

    home = {
      email,
      gpgKey,
      ...
    }: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };

      programs.git = {
        enable = true;

        settings = {
          user.name = fullName;
          user.email = email;

          push.autoSetupRemote = true;
          init.defaultBranch = "main";
        };

        signing = {
          key = gpgKey;
          signByDefault = true;
          format = "openpgp";
        };
      };
    };

    homeDarwin = {
      programs.git.settings.credential.helper = "osxkeychain";
    };
  };
}
