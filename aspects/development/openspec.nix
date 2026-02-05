{lib, ...}: {
  my.aspects.development = {
    features = [
      ["common" "OpenSpec CLI tool"]
    ];

    home = {pkgs, ...}: let
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
    };
  };
}
