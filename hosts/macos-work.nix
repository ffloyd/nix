{
  my.hosts.macos-work = {
    hostname = "Remote-Roman-Kolesnev";
    username = "roman.kolesnev";
    email = "roman.kolesnev@remote.com";
    gpgKey = "AB33F11BEF576E3D";
    system = "aarch64-darwin";

    aspects = [
      "base"
      "shell"
      "terminal"
      "gpg"
      "development"
      "reverse-proxy"
    ];

    darwin = {
      system.stateVersion = 4;
    };

    home = {
      home.stateVersion = "23.11";
    };
  };
}
