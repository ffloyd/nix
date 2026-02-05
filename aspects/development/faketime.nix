{
  my.aspects.development = {
    features = [
      ["common" "libfaketime for time overrides"]
    ];

    home = {pkgs, ...}: {
      home.packages = [
        pkgs.libfaketime
      ];
    };
  };
}
