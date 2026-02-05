{
  my.aspects.development = {
    features = [
      ["nixos" "Linux TTS fallback"]
    ];

    homeNixos = {pkgs, ...}: {
      home.packages = with pkgs; [
        espeak-ng
      ];

      programs.zsh.shellAliases.say = "espeak-ng";
    };
  };
}
