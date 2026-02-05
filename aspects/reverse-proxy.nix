{config, ...}: {
  my.aspects.reverse-proxy = {
    description = "Local reverse proxy";

    nixos = {pkgs, ...}: {
      services.caddy = {
        enable = true;
        globalConfig = ''
          local_certs
        '';
      };

      networking.firewall.allowedTCPPorts = [80 443];

      # needed for certutils; caddy uses it for certs manipulation
      environment.systemPackages = with pkgs; [nss];
    };

    darwin = {pkgs, ...}: let
      inherit (pkgs) caddy;
    in {
      environment.systemPackages = [
        caddy
      ];

      environment.etc = {
        "Caddyfile".text = ''
          {
            local_certs
          }
        '';
      };

      launchd.daemons.caddy = {
        command = "${caddy}/bin/caddy run --config /etc/Caddyfile";

        environment = {
          HOME = "/var/caddy";
        };

        serviceConfig = {
          KeepAlive = true;

          StandardErrorPath = "/var/caddy/stderr";
          StandardOutPath = "/var/caddy/stdout";
        };
      };

      system.activationScripts.extraActivation.text = ''
        ${caddy}/bin/caddy trust || echo "Cannot add certificates. Please run 'caddy trust' manually."
      '';
    };
  };
}
