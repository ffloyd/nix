# Shell shortcuts for Windows dualboot
{
  my.hosts.nixos-desktop = {
    adjustments = [
      "Windows reboot shortcut"
    ];

    home = {
      programs.zsh.shellAliases = {
        os-reboot-to-windows = "sudo systemctl reboot --boot-loader-entry=windows_11.conf";
      };
    };
  };
}
