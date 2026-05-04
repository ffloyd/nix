{config, ...}: {
  perSystem = {pkgs, ...}: {
    packages = let
      version = "v0.4.3";
      longDescription = ''
        Develop, test, and review alongside your web app, in the browser.
        Works with your favorite coding agent and your web framework.
      '';
      license = pkgs.lib.licenses.apsl20;
      platforms = ["x86_64-linux"];
      homepage = "https://tidewave.ai/";
      inherit (pkgs) fetchurl appimageTools stdenv buildFHSEnv;

      tidewave-app = let
        pname = "tidewave-app";
        src = fetchurl {
          url = "https://github.com/tidewave-ai/tidewave_app/releases/download/${version}/tidewave-app-amd64.AppImage";
          hash = "sha256-XQrH31llzaZxY94NAy7xSp/RvOVzo+a+DoHjkv2nD7M=";
        };
        # Extract the AppImage contents so we can grab icons/desktop files
        appimageContents = appimageTools.extract {inherit pname version src;};
      in
        appimageTools.wrapType2 {
          inherit pname version src;

          extraInstallCommands = ''
            install -m 444 -D ${appimageContents}/Tidewave.desktop \
              $out/share/applications/${pname}.desktop

            cp -r ${appimageContents}/usr/share/icons $out/share/
          '';

          meta = {
            inherit longDescription license platforms homepage;
            description = "Tidewave Desktop app";
            downloadPage = "https://github.com/tidewave-ai/tidewave_app/releases";
          };
        };

      tidewave-cli-unwrapped = stdenv.mkDerivation rec {
        pname = "tidewave-cli";
        inherit version;

        src = fetchurl {
          url = "https://github.com/tidewave-ai/tidewave_app/releases/download/${version}/tidewave-cli-x86_64-unknown-linux-gnu";
          hash = "sha256-CReL8t+fIdOjNXB+hYNBZUtuO5YASf4gdac0/80UQk4=";
        };

        dontUnpack = true; # it's a single binary, no archive to unpack
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          install -m755 -D $src $out/bin/${pname}
          runHook postInstall
        '';
      };

      tidewave-cli = buildFHSEnv {
        inherit (tidewave-cli-unwrapped) pname version meta;

        runScript = "tidewave-cli";

        targetPkgs = pkgs: [
          tidewave-cli-unwrapped
        ];
      };
    in [tidewave-app tidewave-cli];
  };

  my.aspects.development = {
    features = [
      ["nixos" "Tidewave agent"]
    ];

    homeNixos = {system, ...}: {
      home.packages = with config.flake.packages.${system}; [
        tidewave-app
        tidewave-cli
      ];
    };
  };
}
