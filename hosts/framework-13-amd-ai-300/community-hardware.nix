# Apply community-maintained hardware tweaks for Framework 13
{inputs, ...}: {
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Hardware tweaks made by community (NixOS Hardware project)"
      "Fix shitty auido hardware with software-level adjustments (from NixOS Hardware project)"
    ];

    nixos = {
      imports = [inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series];

      hardware.framework.laptop13.audioEnhancement = {
        enable = true;

        # use
        # $ pw-dump | grep "node.name.*alsa_output"
        # to find the new correct device name if it stopped working after some update
        # rawDeviceName = "alsa_output.pci-0000_c1_00.6.HiFi__Speaker__sink";

        # the correct one when UCM is disabled
        rawDeviceName = "alsa_output.pci-0000_c1_00.6.analog-stereo";
      };
    };
  };
}
