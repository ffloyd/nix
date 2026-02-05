{
  my.aspects.base = {
    features = [
      ["nixos" "NetworkManager"]
      ["nixos" "OpenSSH server"]
      ["nixos" "Firewall"]
    ];

    nixos = {hostname, ...}: {
      networking.hostName = hostname;
      networking.networkmanager.enable = true;

      services.openssh.enable = true;

      networking.firewall = {
        enable = true;

        allowedTCPPorts = [
          5173 # Vite dev server
        ];
      };
    };
  };
}
