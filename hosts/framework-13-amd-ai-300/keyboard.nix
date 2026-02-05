# Adjust internal keyboard behavior
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Keyboard remapping"
    ];

    nixos = {
      services.keyd = {
        enable = true;
        keyboards.default = {
          # they may change after some updates
          # use `nix-shell -p keyd` and then
          # `sudo keyd monitor` to find a correct one if it stopped working
          ids = [
            "0001:0001:70533846" # internal keyboard (first detected ID)
            "0001:0001:09b4e68d" # current ID as of 2025-10-09
          ];
          settings = {
            main = {
              # left alt <-> left cmd
              # this is also done physically on the keyboard
              leftalt = "layer(meta)";
              leftmeta = "layer(alt)";

              # capslock -> (held) ctrl, (tap) ESC
              capslock = "overloadt2(control, esc, 150)";
            };
          };
        };
      };
    };
  };
}
