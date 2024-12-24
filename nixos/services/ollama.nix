{
  pkgs,
  config,
  ...
}: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # nvtop is useful for monitoring GPU load
  environment.systemPackages = with pkgs; [nvtopPackages.nvidia];

  # HTTP is ok while it exposed to LAN only
  services.caddy.virtualHosts."http://ollama.rig.lan".extraConfig = ''
    reverse_proxy {
      to localhost:${toString config.services.ollama.port}
      header_up Host localhost:${toString config.services.ollama.port}
    }
  '';
}
