# Framework 13 laptop (AMD AI-300 series)
{
  my.hosts.framework-13-amd-ai-300 = {
    hostname = "framework13";
    username = "ffloyd";
    system = "x86_64-linux";

    aspects = [
      "base"
      "shell"
      "terminal"
      "gpg"
      "development"
      "desktop"
      "browser"
      "gaming"
      "reverse-proxy"
      "vtt-server"
    ];

    nixos = {
      system.stateVersion = "25.05";
    };

    home = {
      home.stateVersion = "24.11";
    };
  };
}
