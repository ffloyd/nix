{
  my.aspects.development = {
    features = [
      ["common" "Delta for enhanced git diffs"]
    ];

    home = {
      programs.delta = {
        enable = true;
        enableGitIntegration = true;

        options = {
          features = "decorations";
          side-by-side = true;
          relative-paths = true;
          line-numbers = false;
        };
      };
    };

    homeDarwin = {
      programs.delta.options.syntax-theme = "TwoDark";
    };

    homeNixos = {
      programs.delta.options.syntax-theme = "gruvbox-dark";
    };
  };
}
