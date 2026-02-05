{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink mkDotfilesDirectoryEntriesSymlinks;
in {
  my.aspects.development = {
    features = [
      ["common" "OpenCode configuration"]
    ];

    home = {
      pkgs,
      config,
      system,
      ...
    }: let
      commitInstructions = builtins.readFile ./ai-tooling/commit-instructions.md;
      reviewStagedInstructions = builtins.readFile ./ai-tooling/review-staged-instructions.md;

      commitStagedCommand = ''
        ---
        description: Commits staged changes with a well-structured message.
        agent: plan
        subtask: false
        ---

        ${commitInstructions}
      '';

      reviewStagedCommand = ''
        ---
        description: Review staged changes and provide detailed analysis
        agent: plan
        subtask: false
        ---

        ${reviewStagedInstructions}
      '';

      opencode-npm-dir = ".opencode-npm";
      opencode-npm-dir-full = "${config.home.homeDirectory}/${opencode-npm-dir}";
      # Many MCP servers are npm packages that need to be installed at runtime.
      # We wrap opencode to set up an isolated npm prefix directory so plugin
      # installations don't pollute the global npm prefix or require sudo.
      opencode-adjusted = pkgs.symlinkJoin {
        name = "opencode-adjusted";
        paths = [
          inputs.opencode.packages.${system}.default
        ];
        nativeBuildInputs = [
          pkgs.makeWrapper
        ];
        postBuild = ''
          wrapProgram $out/bin/opencode \
            --prefix PATH : ${lib.makeBinPath [pkgs.nodejs]} \
            --prefix PATH : "${opencode-npm-dir-full}/bin" \
            --set NPM_CONFIG_PREFIX "~/${opencode-npm-dir}"
        '';
      };
    in {
      home.packages = [
        opencode-adjusted
      ];

      xdg.configFile = lib.mkMerge [
        {
          "opencode/opencode.jsonc".source = mkOutOfStoreSymlink config "opencode/opencode.jsonc";
          "opencode/AGENTS.md".source = mkOutOfStoreSymlink config "ai-shared/coding-rules.md";

          "opencode/command/commit-staged.md".text = commitStagedCommand;
          "opencode/command/review-staged.md".text = reviewStagedCommand;
        }
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/command" "opencode/command")
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/agent" "opencode/agent")
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/plugin" "opencode/plugin")
      ];
    };
  };
}
