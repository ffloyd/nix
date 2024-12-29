{
  pkgs,
  inputs,
  private,
  ...
}: let
  caddy = pkgs.caddy;
in {
  services.dnsmasq = {
    enable = true;
    addresses = {
      # I want all *.test domains to point to localhost
      test = "127.0.0.1";
      "lb.here" = "127.0.0.1";
    };
  };

  environment.systemPackages = [caddy];

  #
  # I need a reverse HTTPS proxy for my projects to be able to access
  # them via URLs like https://myproject.test
  #
  environment.etc."Caddyfile".text = ''
    {
      local_certs
    }

    https://lb.here {
      reverse_proxy localhost:8080
    }

    ${private.workProjectsCaddyfile}
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
