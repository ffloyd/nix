{
  config,
  pkgs,
  private,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = private.nixOsUsername;
  home.homeDirectory = "/home/${private.nixOsUsername}";

  imports = [
    ../hm/zsh.nix
    ../hm/git.nix
    ../hm/devtools.nix
    ../hm/gpg.nix
    ../hm/neovim.nix
    ../hm/terminal.nix
    ../hm/webos.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # essential GUI apps
    _1password-gui
    chromium
    telegram-desktop
    spotify

    # GNOME adjustment
    gnome-tweaks
    gnomeExtensions.appindicator

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Gnome settings
  dconf = {
    enable = true;

    settings."org/gnome/Console" = {
      audible-bell = false;
      use-system-font = false;
      custom-font = "IosevkaTerm Nerd Font Mono 10";
    };

    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  programs.zsh.shellAliases = {
    reboot-to-windows = "sudo systemctl reboot --boot-loader-entry=windows_11.conf";
    os-rebuild = "sudo nixos-rebuild switch --flake ~/nix";
    os-rebuild-boot = "sudo nixos-rebuild boot --flake ~/nix";
    os-gc = "sudo nix-collect-garbage -d";
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };
}
