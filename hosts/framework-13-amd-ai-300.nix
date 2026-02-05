# Framework 13 laptop (AMD AI-300 series)
{config, ...}: {
  my.hosts.framework-13-amd-ai-300 = {
    hostname = "framework13";
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
      gaming
      reverse-proxy
      vtt-server
    ];
  };
}
