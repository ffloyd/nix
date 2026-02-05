{
  my.aspects.base = {
    features = [
      ["nixos" "PipeWire with ALSA and PulseAudio compatibility"]
    ];

    nixos = {
      # Consider using pw-cli, pw-mon, pw-top, wpctl commands
      # for low-level inspection and control.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;
      };
    };
  };
}
