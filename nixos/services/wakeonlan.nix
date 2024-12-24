{pkgs, ...}: {
  # Make sure Wake on LAN is enabled after each shutdown/reboot
  systemd.services.wol = {
    description = "Enable Wake-on-LAN";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    script = ''
      IFACE=$(ip addr | awk '/state UP/ {print $2}' | sed 's/.$//')

      echo "Enabling Wake-on-LAN on $IFACE..."
      ethtool -s $IFACE wol g
      echo "Done"
    '';
    path = with pkgs; [iproute2 gawk gnused ethtool];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = ["multi-user.target"];
  };
}
