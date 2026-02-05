# Desktop machine
{config, ...}: {
  my.hosts.nixos-desktop = {
    hostname = "nixos";
    username = "ffloyd";
    system = "x86_64-linux";

    adjustments = [
      "Host profile"
    ];

    aspects = with config.my.aspects; [
      base
      shell
      terminal
      gpg
      development
      desktop
      browser
      reverse-proxy
      wakeonlan
    ];
  };
}
