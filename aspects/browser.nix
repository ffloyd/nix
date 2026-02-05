{inputs, ...}: {
  my.aspects.browser = {
    description = "Web browser and related tools";
    features = [
      ["nixos" "Zen browser with policies and Stylix theming"]
      ["nixos" "Chromium package"]
    ];

    nixos = {
      home-manager.sharedModules = [
        inputs.zen-browser.homeModules.beta
      ];
    };

    homeNixos = {pkgs, ...}: {
      programs.zen-browser = {
        enable = true;

        policies = {
          DisableAppUpdate = true;
          DontCheckDefaultBrowser = false;

          # I'm using Proton Pass extension for this
          OfferToSaveLogins = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
        };
      };

      stylix.targets.zen-browser = {
        enable = true;
        profileNames = ["Default Profile"];
      };

      home.packages = [
        pkgs.chromium
      ];
    };
  };
}
