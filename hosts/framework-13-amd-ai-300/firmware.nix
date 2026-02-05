#  Enable firmware updates for Framework 13
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Firmware updates"
    ];

    nixos = {username, ...}: {
      hardware.enableAllFirmware = true;
      services.fwupd.enable = true;
      home-manager.users.${username}.programs.zsh.shellAliases = {
        os-firmware-check-updates = "fwupdmgr refresh && fwupdmgr get-updates";
        os-firmware-update = "fwupdmgr update";
      };
    };
  };
}
