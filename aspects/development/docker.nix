{
  my.aspects.development = {
    features = [
      ["common" "Docker client and Colima"]
    ];

    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        colima # Docker Desktop is a paid service now, heh
        docker-client
      ];
    };
  };
}
