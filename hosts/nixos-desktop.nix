# Desktop machine
{
  my.hosts.nixos-desktop = {
    hostname = "nixos";
    username = "ffloyd";
    system = "x86_64-linux";

    adjustments = [
      "Host profile"
    ];

    aspects = [
      "base"
      "shell"
      "terminal"
      "gpg"
      "development"
      "desktop"
      "browser"
      "reverse-proxy"
      "wakeonlan"
    ];
  };
}
