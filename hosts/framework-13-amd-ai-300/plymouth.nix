# Objective: Beautify boot process with Plymouth
#
# Unresolved Plymouth issues at the moment of writing:
# - Plymouth sometimes fails and boot happens in text mode (but everything else works)
#
# Resolved Plymouth issues:
# - When external monitor is connected, Plymouth is rendered on it with bad placement
#   | switching to nixos-bgrt theme fixed it
{...}: let
  plymouthModule = {pkgs, ...}: {
    # the latest released version of Plymouth at the moment of writing
    # sometimes fails to load on boot with amdgpu driver and causes boot to happen in text mode
    # here I found a workaround: https://github.com/NixOS/nixpkgs/issues/332812
    nixpkgs.overlays = [
      (final: prev: {
        plymouth = prev.plymouth.overrideAttrs ({src, ...}: {
          version = "24.004.60-unstable-2024-08-28";

          src = src.override {
            rev = "ea83580a6d66afd2b37877fc75248834fe530d99";
            hash = "sha256-GQzf756Y26aCXPyZL9r+UW7uo+wu8IXNgMeJkgFGWnA=";
          };
        });
      })
    ];

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
  };
in {
  hosts.framework-13-amd-ai-300.nixosModules = [plymouthModule];
}
