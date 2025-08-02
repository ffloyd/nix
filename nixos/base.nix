#
# I want this options to be set on all my NixOS machines.
#
{
  pkgs,
  globals,
  private,
  username,
  hostname,
  ...
}: {
  #
  # Nix(pkgs) should be configured in the same way on all my NixOS machines.
  #
  nix.settings.experimental-features = globals.nixExperimentalFeatures;
  nixpkgs.config.allowUnfree = true;

  #
  # User and hostname
  #
  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    description = private.fullName;
    extraGroups = ["networkmanager" "wheel"];
    packages = [];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true; # Otherwise cannot use zsh as shell

  #
  # System-wide fonts
  #
  fonts = {
    enableDefaultFonts = true;
    packages = globals.getFonts pkgs;
  };

  #
  # I never need CapsLock, so I remap it to Ctrl (hold) and ESC (tap)
  #
  # https://mort.io/blog/keymapping-reprise/
  #
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          # capslock -> (held) ctrl, (tap) ESC
          capslock = "overloadt2(control, esc, 150)";
        };
      };
    };
  };

  #
  # Locale & timezone settings
  #
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

  #
  # I want my NixOS machines to be accessible via SSH
  #
  services.openssh.enable = true;

  #
  # I want at least basic NeoVim be accessible to the root user
  # alongside with some essential CLI tools.
  #
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

  #
  # I use networkmanager to manage my network connections
  #
  networking.networkmanager.enable = true;

  #
  # Any NixOS machine should be able to use printers
  #
  services.printing.enable = true;

  #
  # Enable modern sound subsystem
  #
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
