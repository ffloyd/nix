{
  config,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    home.packages = [pkgs.rclone];

    systemd.user.services.rclone-mounts = {
      Unit = {
        Description = "Mount all rClone configurations";
      };

      Install.WantedBy = ["default.target"];

      Service = let
        home = config.home-manager.users.${username}.home.homeDirectory;
        bin_paths = pkgs.lib.makeBinPath (with pkgs; [rclone coreutils gnused]);
      in {
        Type = "forking";

        # /run/wrappers/bin/ is needed for fusermount3 wrapper with correct permissions
        Environment = ["PATH=/run/wrappers/bin/:${bin_paths}:$PATH"];

        ExecStartPre = "${pkgs.writeShellScript "rClonePre" ''
          remotes=$(rclone --config=${home}/.config/rclone/rclone.conf listremotes)
          for remote in $remotes;
          do
            name=$(echo "$remote" | sed "s/://g")
            mkdir -p ${home}/"$name"
          done
        ''}";

        ExecStart = "${pkgs.writeShellScript "rCloneStart" ''
          remotes=$(rclone --config=${home}/.config/rclone/rclone.conf listremotes)
          for remote in $remotes;
          do
          name=$(echo "$remote" | sed "s/://g")
          rclone \
            --config=${home}/.config/rclone/rclone.conf \
            --vfs-cache-mode full \
            --file-perms 0600 \
            --dir-perms 0700 \
            mount "$remote" "$name" &
          done
        ''}";

        ExecStop = "${pkgs.writeShellScript "rCloneStop" ''
          remotes=$(rclone --config=${home}/.config/rclone/rclone.conf listremotes)
          for remote in $remotes;
          do
          name=$(echo "$remote" | sed "s/://g")
          fusermount3 -u ${home}/"$name"
          done
        ''}";

        Restart = "on-failure";
        RestartSec = "30s";
      };
    };
  };
}
