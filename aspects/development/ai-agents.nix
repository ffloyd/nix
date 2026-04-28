{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink mkDotfilesDirectoryEntriesSymlinks;

  # Shared instruction templates - read once, used by both OpenCode and Claude commands
  commitInstructions = builtins.readFile ./ai-tooling/commit-instructions.md;
  reviewStagedInstructions = builtins.readFile ./ai-tooling/review-staged-instructions.md;
in {
  my.aspects.development = {
    features = [
      ["common" "OpenCode configuration"]
      ["common" "GitHub Copilot CLI"]
      ["macos" "Claude Code configuration"]
    ];

    nixos = {
      nix.settings = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
    };

    home = {
      pkgs,
      config,
      system,
      ...
    }: let
      opencodeCommitStagedCommand = ''
        ---
        description: Commits staged changes with a well-structured message.
        agent: plan
        subtask: false
        ---

        ${commitInstructions}
      '';

      opencodeReviewStagedCommand = ''
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
          inputs.llm-agents.packages.${system}.opencode
          pkgs.uv # for some MCP servers like Kagi
          pkgs.python3
        ];
        nativeBuildInputs = [
          pkgs.makeWrapper
        ];
        #
        # UV_PYTHON is required for proper uv/uvx functioning
        # KAGI_API_KEY is essential for Kagi MCP server to work
        # Not sure that it's the best way to pass it to OpenCode, though
        #
        postBuild = ''
          wrapProgram $out/bin/opencode \
            --prefix PATH : ${lib.makeBinPath [pkgs.nodejs]} \
            --prefix PATH : "${opencode-npm-dir-full}/bin" \
            --set NPM_CONFIG_PREFIX "~/${opencode-npm-dir}" \
            --set UV_PYTHON "${pkgs.python3}/bin/python3" \
            --run "export KAGI_API_KEY=\$(${pkgs.pass}/bin/pass kagi-api-key)"
        '';
      };
    in {
      home.packages = [
        opencode-adjusted
        inputs.llm-agents.packages.${system}.pi
      ];

      xdg.configFile = lib.mkMerge [
        {
          "opencode/opencode.jsonc".source = mkOutOfStoreSymlink config "opencode/opencode.jsonc";
          "opencode/tui.jsonc".source = mkOutOfStoreSymlink config "opencode/tui.jsonc";
          "opencode/AGENTS.md".source = mkOutOfStoreSymlink config "ai-shared/coding-rules.md";

          "opencode/command/commit-staged.md".text = opencodeCommitStagedCommand;
          "opencode/command/review-staged.md".text = opencodeReviewStagedCommand;
        }
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/command" "opencode/command")
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/agent" "opencode/agent")
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/plugin" "opencode/plugin")
      ];
    };

    # I do not need Claude on my personal machine,
    # because it's shitty software.
    # So I installed it on working Mac only
    # because sometimes I need it for work.
    homeDarwin = {
      config,
      system,
      ...
    }: {
      home.packages = [
        inputs.llm-agents.packages.${system}.claude-code
      ];

      home.file = {
        ".claude/CLAUDE.md".source = mkOutOfStoreSymlink config "ai-shared/coding-rules.md";
        ".claude/settings.json".source = mkOutOfStoreSymlink config "claude/settings.json";
      };
    };
  };
}
