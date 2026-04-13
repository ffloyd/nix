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
      inherit (pkgs.stdenv) isLinux;
      opencode-adjusted = pkgs.symlinkJoin {
        name = "opencode-adjusted";
        paths = [
          (
            if isLinux
            then inputs.opencode-linux.packages.${system}.default
            else inputs.opencode-darwin.packages.${system}.default
          )
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
        pkgs.kdotool # used by @mohak34/opencode-notifier
        inputs.nix-ai-tools.packages.${system}.copilot-cli
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
    }: let
      claudeCommitStagedCommand = ''
        ---
        description: Commits staged changes with a well-structured message.
        allowed-tools: Glob, Grep, LS, Read, Bash(git status --porcelain), Bash(git diff --cached), Bash(git log:*), Bash(git commit:*)
        ---

        ${commitInstructions}
      '';

      claudeReviewStagedCommand = ''
        ---
        description: Reviews staged changes and provides detailed analysis before committing.
        allowed-tools: Bash, Git, Glob, Grep, LS, Read
        ---

        ${reviewStagedInstructions}
      '';
    in {
      home.packages = [
        inputs.nix-ai-tools.packages.${system}.claude-code
      ];

      home.file = lib.mkMerge [
        (mkDotfilesDirectoryEntriesSymlinks config "claude/commands" ".claude/commands")
        {
          ".claude/CLAUDE.md".source = mkOutOfStoreSymlink config "ai-shared/coding-rules.md";
          ".claude/commands/commit-staged.md".text = claudeCommitStagedCommand;
          ".claude/commands/review-staged.md".text = claudeReviewStagedCommand;
          ".claude/settings.json".source = mkOutOfStoreSymlink config "claude/settings.json";
        }
      ];
    };
  };
}
