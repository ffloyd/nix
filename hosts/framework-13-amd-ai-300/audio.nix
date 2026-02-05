# Objective: Audio enhancement for Framework 13 (original sound is poor)
{...}: {
  hosts.framework-13-amd-ai-300.nixosModules = [
    {
      hardware.framework.laptop13.audioEnhancement = {
        enable = true;

        # use
        # $ pw-dump | grep "node.name.*alsa_output"
        # to find the new correct device name if it stopped working after some update
        # rawDeviceName = "alsa_output.pci-0000_c1_00.6.HiFi__Speaker__sink";

        # the correct one when UCM is disabled
        rawDeviceName = "alsa_output.pci-0000_c1_00.6.analog-stereo";
      };
    }
  ];
}
