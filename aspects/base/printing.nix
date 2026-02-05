{
  my.aspects.base = {
    features = [
      ["nixos" "CUPS printing"]
      ["nixos" "Support for Brother printers"]
      ["nixos" "Avahi for IPP printer discovery"]
    ];

    nixos = {
      pkgs,
      username,
      ...
    }: {
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
    };
  };
}
