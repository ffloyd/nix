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
      ["common" "Claude Code configuration"]
    ];

    home = {
      config,
      system,
      ...
    }: let
      commitInstructions = builtins.readFile ./ai-tooling/commit-instructions.md;
      reviewStagedInstructions = builtins.readFile ./ai-tooling/review-staged-instructions.md;

      commitStagedCommand = ''
        ---
        description: Commits staged changes with a well-structured message.
        allowed-tools: Glob, Grep, LS, Read, Bash(git status --porcelain), Bash(git diff --cached), Bash(git log:*), Bash(git commit:*)
        ---

        ${commitInstructions}
      '';

      reviewStagedCommand = ''
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
          ".claude/commands/commit-staged.md".text = commitStagedCommand;
          ".claude/commands/review-staged.md".text = reviewStagedCommand;
          ".claude/settings.json".source = mkOutOfStoreSymlink config "claude/settings.json";
        }
      ];
    };
  };
}
