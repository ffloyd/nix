{
  my.aspects.nvidia-ai = {
    features = [
      ["nixos" "Ollama with CUDA acceleration"]
    ];

    nixos = {
      config,
      pkgs,
      ...
    }: {
      services.ollama = {
        enable = true;
        acceleration = "cuda";
      };

      # nvtop is useful for monitoring GPU load
      environment.systemPackages = with pkgs; [nvtopPackages.nvidia];

      # HTTP is ok while it exposed to LAN only
      services.caddy.virtualHosts."http://ollama.local".extraConfig = ''
        reverse_proxy {
          to localhost:${toString config.services.ollama.port}
          header_up Host localhost:${toString config.services.ollama.port}
        }
      '';
    };
  };
}
