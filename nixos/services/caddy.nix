{pkgs, ...}: {
  services.caddy = {
    enable = true;
    globalConfig = ''
      local_certs
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  # needed for certutils; caddy uses it for certs manipulation
  environment.systemPackages = with pkgs; [nss];
}
