# Objective: Fix WiFi issues with Intel AX210 card
{...}: {
  hosts.framework-13-amd-ai-300.nixosModules = [
    {
      boot.extraModprobeConfig = ''
        options iwlwifi power_save=0 swcrypto=0
      '';
    }
  ];
}
