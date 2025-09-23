#
# Machine-specific NixOS configuration for Framework 13 laptop (AMD AI-300 series)
#
# Objective: Centralize machine-specific configurations while keeping the rest of the config clean
# of device-specific workarounds. Machine-specific tweaks may exist in other modules when extraction
# here would be inconvenient, but this file should contain the majority of hardware-dependent configuration.
{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    #
    # State versions
    #
    {
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.05"; # Did you read the comment?

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home-manager.users.${username}.home.stateVersion = "24.11"; # Please read the comment before changing.
    }

    #
    # Hardware setup
    #
    ./hardware-configuration.nix
    # apply community-maintained hardware tweaks for the laptop
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    # Apply audio enchancement made by community
    # Original audio sound on Framework 13 is awful =(
    {
      hardware.framework.laptop13.audioEnhancement = {
        enable = true;

        # use
        # $ pw-dump | grep "node.name.*alsa_output"
        # to find the new correct device name if it stopped working after some update
        rawDeviceName = "alsa_output.pci-0000_c1_00.6.HiFi__Speaker__sink";
      };
    }
    # Firmware updates
    {
      hardware.enableAllFirmware = true;
      services.fwupd.enable = true;
      home-manager.users.${username}.programs.zsh.shellAliases = {
        os-firmware-check-updates = "fwupdmgr refresh && fwupdmgr get-updates";
        os-firmware-update = "fwupdmgr update";
      };
    }
    # This is required for proper power management
    {
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    }
    # Bluetooth
    {
      hardware.bluetooth.enable = true;
    }
    # Fix cyrrent WiFi issues
    # I replaced the stock WiFi card with Intel AX210
    # But it still requires some tweaks to work properly
    {
      boot.extraModprobeConfig = ''
        options iwlwifi power_save=0 swcrypto=0
      '';
    }
    # hardware-specific software
    {
      home-manager.users.${username}.home.packages = with pkgs; [
        nvtopPackages.amd
      ];
    }

    #
    # Bootloader, kernel and disk encryption
    #
    {
      # Decrypt LUKS partitions on boot
      boot.initrd.luks.devices."luks-584448a8-c11d-4f10-828a-31a1267eef0f".device = "/dev/disk/by-uuid/584448a8-c11d-4f10-828a-31a1267eef0f";

      # Use latest kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # `systemd-boot` works with minimal config and very reliable.
      # But it looks bad on hdpi. Pressing `r` once sytemd-boot is loaded
      # will switch to consolemod with lower resolution, so it's not a problem
      # considering that we hide boot menu by default.
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;

        # show menu it only if user spams some button
        # this trick will preserve Framework logo on boot.
        timeout = 0;
      };
    }

    #
    # Plymounth: beautify boot process
    #
    # Unresolved Plymouth issues at the moment of writing:
    #
    # - Plymouth sometimes fails and boot happens in text mode (but everything else works)
    #
    # Resolved Plymouth issues:
    #
    # - When external monitor is connected, Plymouth is rendered on it with bad placement
    #   | switching to nixos-bgrt theme fixed it
    {
      # Silent boot: so Framework logo will be replaced with Plymouth seamless
      boot.consoleLogLevel = 0;
      boot.initrd.verbose = false;
      boot.kernelParams = [
        # this two makes initrd really quiet
        "quiet"
        "udev.log_level=3"
        # required by Plymouth
        "splash"
        # allow Plymouth to render before amdgpu driver is loaded
        # by reusing EFI's simpledrm
        "plymouth.use-simpledrm"
        # this (maybe) reduces flickering on boot
        "amdgpu.seamless=1"
      ];

      # Plymouth: make loading screen look nice
      boot.initrd.systemd.enable = true;
      boot.plymouth = {
        enable = true;
        theme = "nixos-bgrt";
        themePackages = [
          pkgs.nixos-bgrt-plymouth
        ];
      };
    }

    #
    # Adjust internal keyboard behavior
    #
    {
      services.keyd = {
        enable = true;
        keyboards.default = {
          ids = ["0001:0001:70533846"];
          settings = {
            main = {
              # left alt <-> left cmd
              # this is also done physically on the keyboard
              leftalt = "leftmeta";
              leftmeta = "leftalt";

              # capslock -> (held) ctrl, (tap) ESC
              capslock = "overloadt2(control, esc, 150)";
            };
          };
        };
      };
    }
  ];
}
