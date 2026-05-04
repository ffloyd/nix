{...}: {
  my.hosts.macos-work = {
    adjustments = [
      "Local apps domain resolver & reverse-proxy config"
    ];

    darwin = {pkgs, config, ...}: let
      inherit (pkgs) dnsmasq;
      dnsmasqPort = "53";
      dnsmasqBind = "127.0.0.1";
    in {
      age.secrets.caddyfile = {
        file = ../../secrets/Caddyfile.work;
        mode = "644";
      };

      environment.systemPackages = [
        dnsmasq
      ];

      environment.etc = {
        "resolver/test".text = ''
          port ${dnsmasqPort}
          nameserver ${dnsmasqBind}
        '';
      };

      environment.etc."Caddyfile".text = ''
        import ${config.age.secrets.caddyfile.path}
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
