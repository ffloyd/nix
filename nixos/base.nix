# Objective: a convinient foundation applicable to both PC & server
{
  inputs,
  config,
  ...
}: let
  config' = config;
in {
  flake.nixosModules.base = {
    pkgs,
    config,
    username,
    hostname,
    system,
    ...
  }: {
    imports = [
      #
      # Nix & related tools
      #
      inputs.nixos-cli.nixosModules.nixos-cli
      {
        services.nixos-cli = {
          enable = true;
          config = {
            config_location = "/home/${username}/nix";
            use_nvd = true;
            apply.use_nom = true;
          };
        };

        nix.settings = {
          substituters = ["https://watersucks.cachix.org"];
          trusted-public-keys = [
            "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
          ];
        };

        # Allow user to use nix features that require elevated privileges
        # (e.g., managing binary caches).
        nix.settings.trusted-users = ["root" username];

        environment.systemPackages = [
          inputs.nix-inspect.packages.${system}.default
          pkgs.nix-tree

          # used by nixos-cli:
          pkgs.nix-output-monitor
          pkgs.nvd
        ];

        home-manager.users.${username}.programs.zsh.shellAliases = {
          # os-rebuild = "sudo nixos-rebuild switch --flake ~/nix";
          # os-rebuild-boot = "sudo nixos-rebuild boot --flake ~/nix --install-bootloader";
          # os-gc = "sudo nix-collect-garbage -d";
          os-rebuild = "nixos apply";
          os-rebuild-boot = "nixos apply --no-activate --install-bootloader";
          os-gc = "nixos generation delete --min 5 --all";

          nixpkgs-search-exec = "nix-env -qaP";
        };
      }

      #
      # User
      #
      {
        users.users.${username} = {
          isNormalUser = true;
          description = config'.private.fullName;
          extraGroups = ["networkmanager" "wheel"];
          packages = [];
          shell = pkgs.zsh;
        };

        programs.zsh.enable = true; # Otherwise cannot use zsh as shell
      }

      #
      # Network
      #
      {
        networking.hostName = hostname;
        networking.networkmanager.enable = true;

        services.openssh.enable = true;

        # Firewall setup
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [
            5173 # Vite dev server
          ];
        };
      }

      #
      # Locale & timezone
      #
      {
        time.timeZone = config'.private.timezone;
        i18n.defaultLocale = config'.private.locale;

        i18n.extraLocaleSettings = {
          LC_ADDRESS = config'.private.extraLocale;
          LC_IDENTIFICATION = config'.private.extraLocale;
          LC_MEASUREMENT = config'.private.extraLocale;
          LC_MONETARY = config'.private.extraLocale;
          LC_NAME = config'.private.extraLocale;
          LC_NUMERIC = config'.private.extraLocale;
          LC_PAPER = config'.private.extraLocale;
          LC_TELEPHONE = config'.private.extraLocale;
          LC_TIME = config'.private.extraLocale;
        };
      }

      #
      # Enable modern sound subsystem
      #
      {
        # Consider using pw-cli, pw-mon, pw-top, wpctl commands
        # for lov-level inspection and control.
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          # If you want to use JACK applications, uncomment this
          # jack.enable = true;
        };
      }

      #
      # Root shell environment
      #
      {
        # I want at least basic NeoVim be accessible to the root user
        # alongside with some essential CLI tools.
        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          defaultEditor = true;
        };

        environment.systemPackages = with pkgs; [
          bat
          eza
          wget
        ];
      }

      #
      # Global Fonts
      #
      {
        fonts = {
          enableDefaultPackages = true;
          packages = config'.globals.getFonts pkgs;
        };
      }

      #
      # Stylix - global theming system
      #
      inputs.stylix.nixosModules.stylix
      {
        stylix = {
          enable = true;
          autoEnable = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
          image = ./desktop/bg.jpg;

          fonts = {
            monospace = {
              name = "IosevkaTerm Nerd Font Mono";
              package = pkgs.nerd-fonts.iosevka-term;
            };
            serif = {
              name = "Iosevka Nerd Font Propo";
              package = pkgs.nerd-fonts.iosevka;
            };
            sansSerif = config.stylix.fonts.serif;
            emoji = config.stylix.fonts.serif;
          };
        };
      }

      #
      # Any NixOS machine should be able to use printers
      #
      {
        services.printing = {
          enable = true;
          drivers = with pkgs; [
            gutenprint
            brgenml1lpr
            brgenml1cupswrapper
          ];
        };

        # needed for IPP printers support
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        # otherwise CUPS can be slow
        services.colord.enable = true;

        # I want to be able to manage printers via CUPS web interface
        # without it I can do it, but UI is extremely slow for some reason
        users.users.${username}.extraGroups = ["lpadmin"];
      }

      #
      # Flatpack / flathub support
      #
      # Some applications are only available as flatpaks
      # or has a significant version lag on Nixpkgs (like anytype at the time of writing).
      #
      # I manage flatpak only for user, not system-wide.
      #
      {
        services.flatpak.enable = true;

        home-manager.users.${username} = {
          imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

          home.packages = [pkgs.flatpak];
        };
      }
    ];
  };
}
