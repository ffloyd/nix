{config, ...}: {
  my.hosts.macos-work = {
    adjustments = [
      "Test domain resolver"
    ];

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

      environment.etc."Caddyfile".text = ''
        ${config.my.consts.workProjectsCaddyfile}
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
