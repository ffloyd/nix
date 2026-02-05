# Objective: Set up a local reverse HTTPS proxy for development with custom local domains
{...}: {
  flake.darwinModules.local-reverse-proxy = {
    pkgs,
    lib,
    config,
    ...
  }: let
    config' = config;
    inherit (pkgs) caddy dnsmasq;
    addresses = {
      test = "127.0.0.1";
    };
    dnsmasqPort = 53;
    dnsmasqBind = "127.0.0.1";
    mapA = f: attrs: with builtins; attrValues (mapAttrs f attrs);
    dnsmasqAddressesParamsList = mapA (name: address: "--address=/${name}/${address}") addresses;
    dnsmasqAddressesParams = pkgs.lib.concatStringsSep " " dnsmasqAddressesParamsList;
  in
    lib.mkMerge [
      #
      # I need a dnsmasq to resolve my custom domains to localhost
      #
      {
        environment.systemPackages = [dnsmasq];

        environment.etc = with builtins;
          listToAttrs (map (domain: {
            name = "resolver/${domain}";
            value = {
              enable = true;
              text = ''
                port ${toString dnsmasqPort}
                nameserver ${dnsmasqBind}
              '';
            };
          }) (builtins.attrNames addresses));

        launchd.daemons.dnsmasq = {
          command = "${dnsmasq}/bin/dnsmasq --keep-in-foreground --port=${toString dnsmasqPort} --listen-address=${dnsmasqBind} " + dnsmasqAddressesParams;
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
          };
        };
      }

      #
      # I need a reverse HTTPS proxy for my projects to be able to access
      # them via URLs like https://myproject.test
      #
      {
        environment.systemPackages = [caddy];

        environment.etc."Caddyfile".text = ''
          {
            local_certs
          }

          ${config'.private.workProjectsCaddyfile}
        '';

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
      }
    ];
}
