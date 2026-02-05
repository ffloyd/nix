{config, ...}: let
  inherit (config.my.consts) timezone locale extraLocale;
in {
  my.aspects.base = {
    features = [
      ["nixos" "Timezone and locale settings"]
    ];

    nixos = {
      time.timeZone = timezone;
      i18n.defaultLocale = locale;

      i18n.extraLocaleSettings = {
        LC_ADDRESS = extraLocale;
        LC_IDENTIFICATION = extraLocale;
        LC_MEASUREMENT = extraLocale;
        LC_MONETARY = extraLocale;
        LC_NAME = extraLocale;
        LC_NUMERIC = extraLocale;
        LC_PAPER = extraLocale;
        LC_TELEPHONE = extraLocale;
        LC_TIME = extraLocale;
      };
    };
  };
}
