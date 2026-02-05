{config, ...}: {
  my.hosts.macos-work = {
    hostname = "Remote-Roman-Kolesnev";
    username = "roman.kolesnev";
    system = "aarch64-darwin";

    adjustments = [
      "Host profile"
    ];

    aspects = with config.my.aspects; [
      base
      shell
      terminal
      gpg
      development
      reverse-proxy
    ];
  };
}
