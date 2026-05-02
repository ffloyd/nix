{inputs, ...}: {
  my.aspects.base = {
    features = [
      ["nixos" "OS-level Agenix (age-encrypted secrets)"]
      ["macos" "OS-level Agenix (age-encrypted secrets)"]
      ["common" "Agenix for Home Manager (age-encrypted secrets)"]
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
        identityPaths = ["/home/${username}/.ssh/id_ed25519"];
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

    darwin = {
      config,
      system,
      username,
      inputs,
      pkgs,
      ...
    }: {
      imports = [
        inputs.agenix.darwinModules.default
      ];

      age = {
        identityPaths = ["/Users/${username}/.ssh/id_ed25519"];
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
  };
}
