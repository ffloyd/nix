# Objective: Shell aliases for macOS workflow
{config, ...}: let
  config' = config;
  shellAliasesModule = {username, ...}: {
    programs.zsh = {
      shellAliases = {
        os-rebuild = "sudo darwin-rebuild switch --flake /Users/${username}/nix";
        hm-rebuild = "home-manager switch --flake ~/nix";
        wakeonlan-rig = ''
          curl -X POST -u ${config'.private.routerUsername}:${config'.private.routerPassword} http://${config'.private.routerHost}/rest/tool/wol --data '{"mac": "${config'.private.gamingRigMacAddress}", "interface": "bridge"}' -H "content-type: application/json"
        '';
      };
    };
  };
in {
  hosts.macos-work.homeModules = [shellAliasesModule];
}
