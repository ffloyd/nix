# Hardware-specific software packages
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Hardware-specific packages"
    ];

    nixos = {
      pkgs,
      username,
      ...
    }: {
      home-manager.users.${username}.home.packages = with pkgs; [
        # AMD GPU monitoring tool
        nvtopPackages.amd

        # Wireless network monitoring tool
        wavemon
      ];
    };
  };
}
