# Fix not working internal microphone
# https://github.com/NixOS/nixos-hardware/issues/1603
# https://community.frame.work/t/microphone-not-working-after-nixos-update/74915
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Microphone fix"
    ];

    nixos = {
      services.pipewire.wireplumber.extraConfig.no-ucm = {
        "monitor.alsa.properties" = {
          "alsa.use-ucm" = false;
        };
      };
    };
  };
}
