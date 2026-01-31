# Objective: run a local VTT server of choice (https://vtt.local)
{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.foundryvtt.nixosModules.foundryvtt
  ];

  services.foundryvtt = {
    enable = true;

    hostName = "vtt.ffloyd.space";
    minifyStaticFiles = true;

    upnp = false;

    proxySSL = true;
    proxyPort = 443;

    package = inputs.foundryvtt.packages.${pkgs.system}.foundryvtt_13;
  };

  services.caddy.virtualHosts.${config.services.foundryvtt.hostName}.extraConfig = ''
    reverse_proxy http://localhost:${toString config.services.foundryvtt.port}
  '';

  networking.extraHosts = ''
    127.0.0.1 ${config.services.foundryvtt.hostName}
  '';
}
