# Objective: run a local VTT server of choice (https://vtt.local)
{inputs, ...}: {
  my.aspects.vtt-server = {
    description = "VTT server";

    dependsOn = ["reverse-proxy"];

    features = [
      ["nixos" "Local FoundryVTT server"]
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: let
      inherit (config.services) foundryvtt;
    in {
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

      services.caddy.virtualHosts.${foundryvtt.hostName}.extraConfig = ''
        reverse_proxy http://localhost:${toString foundryvtt.port}
      '';

      networking.extraHosts = ''
        127.0.0.1 ${foundryvtt.hostName}
      '';
    };
  };
}
