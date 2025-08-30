#
# Objective: a canvinient foundation applicable to both PC & server
#
{
  inputs,
  pkgs,
  globals,
  private,
  username,
  hostname,
  ...
}: {
  imports = [
    #
    # Nix & related tools
    #
    inputs.nixos-cli.nixosModules.nixos-cli
    {
      nix.settings.experimental-features = globals.nixExperimentalFeatures;
      nixpkgs.config.allowUnfree = true;

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

      environment.systemPackages = [
        inputs.nix-inspect.packages.${pkgs.system}.default
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
      };
    }

    #
    # User
    #
    {
      users.users.${username} = {
        isNormalUser = true;
        description = private.fullName;
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
    }

    #
    # Locale & timezone
    #
    {
      time.timeZone = private.timezone;
      i18n.defaultLocale = private.locale;

      i18n.extraLocaleSettings = {
        LC_ADDRESS = private.extraLocale;
        LC_IDENTIFICATION = private.extraLocale;
        LC_MEASUREMENT = private.extraLocale;
        LC_MONETARY = private.extraLocale;
        LC_NAME = private.extraLocale;
        LC_NUMERIC = private.extraLocale;
        LC_PAPER = private.extraLocale;
        LC_TELEPHONE = private.extraLocale;
        LC_TIME = private.extraLocale;
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
        packages = globals.getFonts pkgs;
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
          gutenprintBin
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
  ];
}
