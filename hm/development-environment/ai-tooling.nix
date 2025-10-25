# Objective: Centralized AI coding assistant configuration (Claude Code and OpenCode)
{
  inputs,
  pkgs,
  lib,
  config,
  mkDotfilesLink,
  mkDotfilesDirectoryEntriesSymlinks,
  ...
}: {
  imports = [
    # Claude Code configuration
    (let
      commitInstructions = builtins.readFile ./ai-tooling/commit-instructions.md;
      reviewStagedInstructions = builtins.readFile ./ai-tooling/review-staged-instructions.md;

      commitCommand = ''
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
        inputs.nix-ai-tools.packages.${pkgs.system}.claude-code
        # To check how much I spend in "pay per token" equivalent
        # I need it because Claude subscription does not give you a hint if it more
        # beneficial than pay-per-use approach.
        inputs.ccusage-rs.packages.${pkgs.system}.default
      ];

      home.file = lib.mkMerge [
        {
          ".claude/CLAUDE.md".source = mkDotfilesLink config "ai-shared/coding-rules.md";
          ".claude/commands/commit.md".text = commitCommand;
          ".claude/commands/review-staged.md".text = reviewStagedCommand;
          ".claude/settings.json".source = mkDotfilesLink config "claude/settings.json";
        }
        (mkDotfilesDirectoryEntriesSymlinks config "claude/commands" ".claude/commands")
      ];
    })

    # OpenCode configuration
    (let
      commitInstructions = builtins.readFile ./ai-tooling/commit-instructions.md;
      reviewStagedInstructions = builtins.readFile ./ai-tooling/review-staged-instructions.md;

      commitCommand = ''
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
    in {
      home.packages = [
        inputs.nix-ai-tools.packages.${pkgs.system}.opencode
      ];

      xdg.configFile = lib.mkMerge [
        {
          "opencode/opencode.jsonc".source = mkDotfilesLink config "opencode/opencode.jsonc";
          "opencode/AGENTS.md".source = mkDotfilesLink config "ai-shared/coding-rules.md";

          "opencode/command/commit.md".text = commitCommand;
          "opencode/command/review-staged.md".text = reviewStagedCommand;
        }
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/command" "opencode/command")
        (mkDotfilesDirectoryEntriesSymlinks config "opencode/agent" "opencode/agent")
      ];
    })

    # GitHub Copilot CLI
    {
      home.packages = [
        inputs.nix-ai-tools.packages.${pkgs.system}.copilot-cli
      ];
    }

    # OpenSpec framework
    (let
      openspec = pkgs.buildNpmPackage rec {
        pname = "openspec";
        version = "0.12.0";

        src = pkgs.fetchFromGitHub {
          owner = "Fission-AI";
          repo = "OpenSpec";
          rev = "v${version}";
          hash = "sha256-wzdpcvdwzB47Oi/sQzxjgvMbF1RYaz8RyEvm8e6/K3g=";
        };

        pnpmDeps = pkgs.pnpm.fetchDeps {
          inherit pname version src;
          fetcherVersion = 2;
          hash = "sha256-J+Yc9qwS/+t32qqSywJaZwVuqoffeScOgFW6y6YUhIk=";
        };

        npmConfigHook = pkgs.pnpm.configHook;
        npmDeps = pnpmDeps;

        dontNpmPrune = true; # hangs forever on both Linux/darwin

        meta = with lib; {
          description = "Spec-driven development framework for AI coding assistants";
          homepage = "https://github.com/Fission-AI/OpenSpec";
          license = licenses.mit;
          mainProgram = "openspec";
          platforms = platforms.all;
        };
      };
    in {
      home.packages = [openspec];
    })
  ];
}
