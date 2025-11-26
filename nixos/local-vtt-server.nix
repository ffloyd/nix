# Objective: run a local VTT server of choice (https://vtt.local)
{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  imports = [
    inputs.foundryvtt.nixosModules.foundryvtt
  ];

  services.foundryvtt = {
    enable = true;
    package = inputs.foundryvtt.packages.${system}.foundryvtt_12.overrideAttrs {
      majorVersion = 12;
      build = "331";
    };

    hostName = "vtt.local";

    minifyStaticFiles = true;
    upnp = false;

    proxySSL = true;
    proxyPort = 443;
  };

  services.caddy.virtualHosts.${config.services.foundryvtt.hostName}.extraConfig = ''
    reverse_proxy localhost:${toString config.services.foundryvtt.port}
  '';
}
