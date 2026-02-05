# Objective: Font configuration for macOS
{config, ...}: let
  config' = config;
  fontsModule = {
    pkgs,
    username,
    ...
  }: {
    fonts.packages = config'.globals.getFonts pkgs;
    system.primaryUser = username;
  };
in {
  hosts.macos-work.darwinModules = [fontsModule];
}
