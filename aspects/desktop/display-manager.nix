{
  my.aspects.desktop = {
    features = [
      ["nixos" "SDDM display manager setup"]
    ];

    nixos = {pkgs, ...}: {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
        extraPackages = with pkgs; [
          qt6.qtmultimedia # required for astronaut theme
        ];
      };
    };
  };
}
