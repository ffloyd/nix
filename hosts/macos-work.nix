{
  my.hosts.macos-work = {
    hostname = "Remote-Roman-Kolesnev";
    username = "roman.kolesnev";
    email = "roman.kolesnev@remote.com";
    gpgKey = "C201FFD35504A494";
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
