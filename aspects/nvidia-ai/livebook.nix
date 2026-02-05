{
  my.aspects.nvidia-ai = {
    features = [
      ["nixos" "LiveBook with GPU support"]
    ];

    nixos = {
      config,
      pkgs,
      username,
      ...
    }: let
      inherit (pkgs.cudaPackages) cudatoolkit;
      dependencies = [pkgs.gnumake pkgs.gcc cudatoolkit pkgs.cudaPackages.cudnn];
      inherit (pkgs.lib) makeLibraryPath;
    in {
      services.livebook = {
        # the disadvantage here is that I have to log in in order to have it started
        enableUserService = true;
        environment = {
          LIVEBOOK_IP = "127.0.0.1";
          LIVEBOOK_PORT = "8080";

          # passwordless access is okish while it's LAN-local
          LIVEBOOK_TOKEN_ENABLED = "false";

          # https://hexdocs.pm/exla/0.9.2/EXLA.html#module-gpu-runtime-issues
          ELIXIR_ERL_OPTIONS = "+sssdio 128";

          # addDriverRunpath.driverLink is needed for proper libcuda.so linking
          LD_LIBRARY_PATH = "${makeLibraryPath dependencies}:${pkgs.addDriverRunpath.driverLink}/lib";

          # without it XLA cannot find libdevice.10.bc
          XLA_FLAGS = "--xla_gpu_cuda_data_dir=${cudatoolkit}";
        };
        extraPackages = dependencies;
      };

      # prevent starting on other users (like gdm, etc)
      systemd.user.services.livebook.unitConfig.ConditionUser = username;

      services.caddy.virtualHosts."livebook.local".extraConfig = ''
        reverse_proxy localhost:${toString config.services.livebook.environment.LIVEBOOK_PORT}
      '';
    };
  };
}
