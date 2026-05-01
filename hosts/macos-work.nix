{
  my.hosts.macos-work = {
    hostname = "Remote-Roman-Kolesnev";
    username = "roman.kolesnev";
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
