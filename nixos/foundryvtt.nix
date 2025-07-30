{
  pkgs,
  inputs,
  config,
  ...
}: {
  services.foundryvtt = {
    enable = true;
    package = inputs.foundryvtt.packages.${pkgs.system}.foundryvtt_12.overrideAttrs {
      majorVersion = 12;
      build = "331";
    };

    hostName = "vtt.ffloyd.space";

    minifyStaticFiles = true;
    upnp = false;

    proxySSL = true;
    proxyPort = 443;
  };

  services.caddy.virtualHosts.${config.services.foundryvtt.hostName}.extraConfig = ''
    reverse_proxy localhost:${toString config.services.foundryvtt.port}
  '';
}
