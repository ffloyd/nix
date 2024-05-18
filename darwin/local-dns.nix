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

    ${private.workProjectsCaddyfile}
  '';

  launchd.agents.caddy = {
    serviceConfig.ProgramArguments = [
      "${caddy}/bin/caddy"
      "run"
      "--config"
      "/etc/Caddyfile"
    ];

    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;

      EnvironmentVariables = {
        HOME = "/var/caddy";
      };

      StandardErrorPath = "/var/caddy/stderr";
      StandardOutPath = "/var/caddy/stdout";
    };
  };

  system.activationScripts.extraActivation.text = ''
    ${caddy}/bin/caddy trust
  '';
}
