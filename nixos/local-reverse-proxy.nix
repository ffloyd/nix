# Objective: Set up a local reverse HTTPS proxy for development with custom local domains
{...}: {
  flake.nixosModules.local-reverse-proxy = {pkgs, ...}: {
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
}
