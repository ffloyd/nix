# Proper power management for Framework 13 laptop
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Power management"
    ];

    nixos = {
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };
  };
}
