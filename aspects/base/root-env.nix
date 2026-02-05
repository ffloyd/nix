{
  my.aspects.base = {
    features = [
      ["nixos" "Neovim for root user"]
      ["nixos" "Essential CLI tools for root"]
    ];

    nixos = {pkgs, ...}: {
      # I want at least basic NeoVim be accessible to the root user
      # alongside with some essential CLI tools.
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
      };

      environment.systemPackages = with pkgs; [
        bat
        eza
        wget
      ];
    };
  };
}
