# Objective: Enable Bluetooth support for Framework 13
{...}: {
  hosts.framework-13-amd-ai-300.nixosModules = [
    {
      hardware.bluetooth.enable = true;
    }
  ];
}
