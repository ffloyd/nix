{
  config,
  pkgs,
  private,
  ...
}: {
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
}
