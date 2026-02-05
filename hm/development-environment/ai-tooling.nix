# Objective: Centralized AI coding assistant configuration (Claude Code and OpenCode)
{
  inputs,
  lib,
  ...
}: {
  flake.homeModules.development-environment = {
    pkgs,
    config,
    system,
    mkDotfilesLink,
    mkDotfilesDirectoryEntriesSymlinks,
    ...
  }: {
    imports = [
      # Claude Code configuration
      (let
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
          {
            ".claude/CLAUDE.md".source = mkDotfilesLink config "ai-shared/coding-rules.md";
            ".claude/commands/commit-staged.md".text = commitStagedCommand;
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
            "opencode/opencode.jsonc".source = mkDotfilesLink config "opencode/opencode.jsonc";
            "opencode/AGENTS.md".source = mkDotfilesLink config "ai-shared/coding-rules.md";

            "opencode/command/commit-staged.md".text = commitStagedCommand;
            "opencode/command/review-staged.md".text = reviewStagedCommand;
          }
          (mkDotfilesDirectoryEntriesSymlinks config "opencode/command" "opencode/command")
          (mkDotfilesDirectoryEntriesSymlinks config "opencode/agent" "opencode/agent")
          (mkDotfilesDirectoryEntriesSymlinks config "opencode/plugin" "opencode/plugin")
        ];
      })

      # GitHub Copilot CLI
      {
        home.packages = [
          inputs.nix-ai-tools.packages.${system}.copilot-cli
        ];
      }

      # OpenSpec framework
      (let
        openspec = pkgs.buildNpmPackage rec {
          pname = "openspec";
          version = "0.16.0";

          src = pkgs.fetchFromGitHub {
            owner = "Fission-AI";
            repo = "OpenSpec";
            rev = "v${version}";
            hash = "sha256-eBZvgjjEzhoO1Gt4B3lsgOvJ98uGq7gaqdXQ40i0SqY=";
          };

          pnpmDeps = pkgs.pnpm.fetchDeps {
            inherit pname version src;
            fetcherVersion = 2;
            hash = "sha256-qqIdSF41gv4EDxEKP0sfpW1xW+3SMES9oGf2ru1lUnE=";
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
  };
}
