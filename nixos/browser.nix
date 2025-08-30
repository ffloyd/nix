# Objective: browser of choice
{
  inputs,
  username,
  ...
}: {
  home-manager.sharedModules = [
    inputs.zen-browser.homeModules.beta
  ];

  home-manager.users.${username} = {
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
  };
}
