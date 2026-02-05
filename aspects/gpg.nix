{
  my.aspects.gpg = {
    description = "GPG configuration and shell helpers";

    features = [
      ["common" "GPG setup and helper shell functions"]
      ["macos" "Pinentry configuration for macOS"]
      ["nixos" "gpg-agent with SSH support"]
    ];

    home = {
      programs.gpg = {
        enable = true;
      };

      programs.zsh.initContent = ''
        gpg-export-secrets() {
          gpg --export-secret-keys > ''${1:?provide a file name}
        }

        gpg-import() {
          gpg --import ''${1:?provide a file name}
        }

        gpg-export-public() {
          gpg --export -a ''${1:?provide an email}
        }
      '';
    };

    homeDarwin = {pkgs, ...}: {
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac"
      '';
    };

    homeNixos = {
      services.gpg-agent = {
        enable = true;

        enableSshSupport = true;
        enableZshIntegration = true;
      };
    };
  };
}
