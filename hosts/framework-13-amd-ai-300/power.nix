# Objective: Proper power management for Framework 13 laptop
{...}: {
  hosts.framework-13-amd-ai-300.nixosModules = [
    {
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    }
  ];
}
