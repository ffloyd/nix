# Objective: Apply community-maintained hardware tweaks for Framework 13
{inputs, ...}: {
  hosts.framework-13-amd-ai-300.nixosModules = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];
}
