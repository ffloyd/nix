# Desktop machine
{
  my.hosts.nixos-desktop = {
    hostname = "nixos";
    username = "ffloyd";
    email = "roman@ffloyd.space";
    gpgKey = "A16DC4CD1A040EDE";
    system = "x86_64-linux";

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

    nixos = {
      system.stateVersion = "24.11";
    };

    home = {
      home.stateVersion = "24.11";
    };
  };
}
