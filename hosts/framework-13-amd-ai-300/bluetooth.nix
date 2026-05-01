{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Enable Bluetooth"
    ];

    nixos = {
      hardware.bluetooth.enable = true;
    };
  };
}
