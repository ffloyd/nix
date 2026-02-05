# Objective: Shell shortcuts for Windows dualboot
{...}: {
  hosts.nixos-desktop.homeModules = [
    {
      programs.zsh.shellAliases = {
        os-reboot-to-windows = "sudo systemctl reboot --boot-loader-entry=windows_11.conf";
      };
    }
  ];
}
