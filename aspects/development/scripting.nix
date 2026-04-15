{
  my.aspects.development = {
    features = [
      ["common" "CLI tooling for scripts"]
      ["macos" "1Password CLI"]
      ["common" "Proton Pass CLI"]
    ];

    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        # data extraction & processing
        gawk
        jq
        wget

        # secrets management via pass
        (pass.withExtensions (exts: [exts.pass-otp]))

        # Proton Pass CLI
        proton-pass-cli
      ];
    };

    homeDarwin = {pkgs, ...}: {
      home.packages = with pkgs; [
        _1password-cli
      ];
    };
  };
}
