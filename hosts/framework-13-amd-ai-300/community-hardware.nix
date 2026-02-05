# Apply community-maintained hardware tweaks for Framework 13
{inputs, ...}: {
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Community hardware tweaks"
    ];

    nixos = inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series;
  };
}
