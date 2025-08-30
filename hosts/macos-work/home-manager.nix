# Machine-specific home-manager configuration for work MacBook
#
# Objective: Centralize machine-specific configurations while keeping the rest of the config clean
# of device-specific workarounds. Machine-specific tweaks may exist in other modules when extraction
# here would be inconvenient, but this file should contain the majority of hardware-dependent configuration.
{
  pkgs,
  private,
  username,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.zsh = {
    shellAliases = {
      os-rebuild = "sudo darwin-rebuild switch --flake /Users/${username}/nix";
      hm-rebuild = "home-manager switch --flake ~/nix";
      wakeonlan-rig = ''
        curl -X POST -u ${private.routerUsername}:${private.routerPassword} http://${private.routerHost}/rest/tool/wol --data '{"mac": "${private.gamingRigMacAddress}", "interface": "bridge"}' -H "content-type: application/json"
      '';
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
