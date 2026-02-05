# Objective: Shell aliases for macOS workflow
{config, ...}: let
  inherit (config.my.consts) routerUsername routerPassword routerHost gamingRigMacAddress;
in {
  my.hosts.macos-work = {
    adjustments = [
      "Shell aliases"
    ];

    home = {
      programs.zsh = {
        shellAliases = {
          wakeonlan-rig = ''
            curl -X POST -u ${routerUsername}:${routerPassword} http://${routerHost}/rest/tool/wol --data '{"mac": "${gamingRigMacAddress}", "interface": "bridge"}' -H "content-type: application/json"
          '';
        };
      };
    };
  };
}
