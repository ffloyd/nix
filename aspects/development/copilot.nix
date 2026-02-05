{inputs, ...}: {
  my.aspects.development = {
    features = [
      ["common" "GitHub Copilot CLI"]
    ];

    home = {system, ...}: {
      home.packages = [
        inputs.nix-ai-tools.packages.${system}.copilot-cli
      ];
    };
  };
}
