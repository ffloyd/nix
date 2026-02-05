{config, ...}: let
  inherit (config.my.consts) personalEmail workEmail personalGpgKey workGpgKey fullName;
in {
  my.aspects.development = {
    features = [
      ["common" "Git, SSH, and commit signing setup"]
    ];

    home = {pkgs, ...}: {
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
          user.email = personalEmail;

          push.autoSetupRemote = true;
          init.defaultBranch = "main";
        };

        signing = {
          key = personalGpgKey;
          signByDefault = true;
        };

        includes = [
          {
            condition = "gitdir:~/Work/";
            contents = {
              user = {
                email = workEmail;
                signingkey = workGpgKey;
              };
              commit.gpgSign = true;
              tag.gpgSign = true;
              core.sshCommand = "ssh -i ~/.ssh/id_work";
            };
          }
        ];
      };

      home.packages = with pkgs; [
        git-crypt
      ];
    };

    homeDarwin = {
      programs.git.settings.credential.helper = "osxkeychain";
    };
  };
}
