{
  my.aspects.nvidia-ai = {
    features = [
      ["nixos" "Open WebUI on top of Ollama"]
    ];

    nixos = {config, ...}: {
      services.open-webui = {
        enable = true;

        port = 30303;
        environment = {
          # default from NixOS options
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";

          WEBUI_AUTH = "False";
          OLLAMA_BASE_URL = "http://ollama.local";
          ENABLE_OPENAI_API = "False";
        };
      };

      services.caddy.virtualHosts."ai.local".extraConfig = ''
        reverse_proxy localhost:${toString config.services.open-webui.port}
      '';
    };
  };
}
