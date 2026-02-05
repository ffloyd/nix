# Objective: Enable Rosetta 2 for x86_64 compatibility
{...}: {
  hosts.macos-work.darwinModules = [
    {
      # enable Rosetta 2
      system.activationScripts.extraActivation.text = ''
        softwareupdate --install-rosetta --agree-to-license
      '';
    }
  ];
}
