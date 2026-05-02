{config, username, ...}: {
  my.hosts.macos-work = {
    adjustments = [
      "Local apps domain resolver & reverse-proxy config"
    ];

    home = {config, ...}: {
      age.secrets.caddyfile = {
        file = ../../secrets/Caddyfile.work;
        mode = 644;
      };

      home.file.".local.Caddyfile".source = config.age.secrets.caddyfile.path;
    };

    darwin = {pkgs, ...}: let
      inherit (pkgs) dnsmasq;
      dnsmasqPort = "53";
      dnsmasqBind = "127.0.0.1";
    in {
      environment.systemPackages = [
        dnsmasq
      ];

      environment.etc = {
        "resolver/test".text = ''
          port ${dnsmasqPort}
          nameserver ${dnsmasqBind}
        '';
      };

      # Agenix has no imlementation for nix-darwin modules
      # so we do a trick here and "proxy" it through homeManager.
      # Downside: may require manual restart of Caddy after boot.
      environment.etc."Caddyfile".text = ''
        import /Users/${username}/.local.Caddyfile
      '';

      launchd.daemons.dnsmasq = {
        command = "${dnsmasq}/bin/dnsmasq --keep-in-foreground --port=${dnsmasqPort} --listen-address=${dnsmasqBind} --address=/test/127.0.0.1";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    };
  };
}
