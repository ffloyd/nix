{
  my.aspects.base = {
    features = [
      ["macos" "Enable Rosetta 2 (x86_64 compatibility)"]
    ];

    darwin = {
      # enable Rosetta 2 for x86_64 compatibility
      system.activationScripts.extraActivation.text = ''
        softwareupdate --install-rosetta --agree-to-license
      '';
    };
  };
}
