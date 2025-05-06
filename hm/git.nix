{
  config,
  pkgs,
  private,
  ...
}: {
  home.packages = with pkgs; [
    git-crypt
  ];

  programs.git = {
    enable = true;

    userName = private.fullName;
    userEmail = private.personalEmail;

    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      credential.helper = pkgs.lib.mkIf pkgs.stdenv.isDarwin "osxkeychain";
    };

    signing = {
      key = private.personalGpgKey;
      signByDefault = true;
    };

    includes = [
      {
        condition = "gitdir:~/Work/";
        contents = {
          user = {
            email = private.workEmail;
            signingkey = private.workGpgKey;
          };
          commit.gpgSign = true;
          tag.gpgSign = true;
          core.sshCommand = "ssh -i ~/.ssh/id_work";
        };
      }
    ];

    delta = {
      enable = true;

      # check if magit-delta still works after updating this options
      options = {
        features = "decorations";
        side-by-side = true;
        relative-paths = true;
        line-numbers = false;
        syntax-theme = "Nord";
      };
    };
  };

  programs.ssh = {
    enable = true;
  };

  # IDEA: use programs.git-cliff
}
