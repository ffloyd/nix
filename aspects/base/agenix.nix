{inputs, ...}: {
  my.aspects.base = {
    features = [
      ["nixos" "OS-level Agenix for usage in NixOS modules"]
      ["common" "Home-Manager-level Agenix for cross-system secrets (API keys, etc)"]
    ];

    nixos = {
      config,
      system,
      username,
      pkgs,
      ...
    }: {
      imports = [
        inputs.agenix.nixosModules.default
      ];

      age = {
        identityPaths = [ "/home/${username}/.ssh/id_ed25519" ];
        secrets.test.file = ../../secrets/test.age;
      };

      environment.systemPackages = [
        inputs.agenix.packages.${system}.default

        (pkgs.writeShellScriptBin "os-agenix-test" ''
          echo "Test secret path: ${config.age.secrets.test.path}"
          echo "Test secret content:"
          cat ${config.age.secrets.test.path}
        '')
      ];
    };

    home = {
      config,
      system,
      pkgs,
      ...
    }: {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];

      age = {
        identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
        secrets = {
          test.file = ../../secrets/test.age;
        };
      };

      home.packages = [
        inputs.agenix.packages.${system}.default

        (pkgs.writeShellScriptBin "hm-agenix-test" ''
          echo "Test secret path: ${config.age.secrets.test.path}"
          echo "Test secret content:"
          cat ${config.age.secrets.test.path}
        '')
      ];
    };
  };
}
