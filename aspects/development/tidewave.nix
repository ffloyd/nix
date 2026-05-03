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
      inherit (pkgs) fetchurl appimageTools stdenv;
    in {
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

      tidewave-cli = stdenv.mkDerivation rec {
        pname = "tidewave-cli";
        inherit version;

        src = fetchurl {
          url = "https://github.com/tidewave-ai/tidewave_app/releases/download/${version}/tidewave-cli-x86_64-unknown-linux-musl";
          hash = "sha256-TRuoDUyHRXShQm/P1x9OtyAcU8pgw16oZy1TpvXL4UI=";
        };

        dontUnpack = true; # it's a single binary, no archive to unpack
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          install -m755 -D $src $out/bin/${pname}
          runHook postInstall
        '';

        meta = {
          description = "Tidewave CLI";
          inherit longDescription license platforms homepage;
        };
      };
    };
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
