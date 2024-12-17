{pkgs, ...}: {
  home.packages = with pkgs; [
    # Docker stuff
    colima # Docker Desktop is a paid service now, heh
    docker-client

    # password management
    (pass.withExtensions (exts: [exts.pass-otp]))
    _1password-cli

    # nix-related helpers
    nix-tree

    gawk
    jq
    wget
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    extensions = [pkgs.gh-copilot];
    settings = {
      gitProtocol = "ssh";
    };
  };

  # load gh copilot aliases
  programs.zsh.initExtra = ''
    eval "$(gh copilot alias zsh)"
  '';

  programs.gh-dash = {
    enable = true;
  };

  programs.zsh.shellAliases = {
    mfc = "git ls-files --other --modified --exclude-standard | xargs mix format";
  };
}
