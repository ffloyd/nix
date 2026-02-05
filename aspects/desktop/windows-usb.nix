{
  my.aspects.desktop = {
    homeNixos = {pkgs, ...}: {
      home.packages = with pkgs; [
        woeusb
      ];
    };
  };
}
