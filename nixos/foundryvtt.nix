{
  pkgs,
  inputs,
  ...
}: let
  hostName = "vtt.ffloyd.space";
  port = 30000;
in {
  services.foundryvtt = {
    enable = true;
    package = inputs.foundryvtt.packages.${pkgs.system}.foundryvtt_12.overrideAttrs {
      majorVersion = 12;
      build = "331";
    };

    inherit hostName port;

    minifyStaticFiles = true;
    upnp = false;

    proxySSL = true;
    proxyPort = 443;
  };

  services.caddy = {
    enable = true;

    globalConfig = ''
      local_certs
    '';

    virtualHosts.${hostName}.extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };
}
