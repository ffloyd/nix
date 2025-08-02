{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {
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
  }
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".gnupg/gpg-agent.conf" = {
      text = ''
        pinentry-program "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac"
      '';
    };
  })
  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [pkgs.gcr];

    services.gpg-agent = {
      enable = true;

      enableSshSupport = true;
      enableZshIntegration = true;

      pinentry.package = pkgs.pinentry-gnome3;
    };
  })
]
