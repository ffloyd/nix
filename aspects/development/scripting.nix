{
  my.aspects.development = {
    features = [
      ["common" "CLI tooling for scripts"]
      ["macos" "1Password CLI"]
    ];

    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        # data extraction & processing
        gawk
        jq
        wget

        # secrets management
        (pass.withExtensions (exts: [exts.pass-otp]))
      ];
    };

    homeDarwin = {pkgs, ...}: {
      home.packages = with pkgs; [
        _1password-cli
      ];
    };
  };
}
