# NixOS + MacOS configuration

This repository contains my personal configuration for NixOS and MacOS. It's a [Nix](https://brew.sh/) [flake](https://nixos.wiki/wiki/Flakes) that provides configuration modules for both systems.

| Files          | Purpose                                                                                                                                                                 |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `flake.nix`    | The main entry point, defines configuration for two machines: x86_64-linux NixOS and aarch64-darwin MacOS.                                                              |
| `globals.nix`  | An attrs set with some global values. Propogated to all modules.                                                                                                        |
| `private.nix`  | An attrs set with some global values that are personal data. Encrypted by `git-crypt`. Propogated to all modules.                                                       |
| `hm/*.nix`     | [home-manager](https://github.com/nix-community/home-manager) configuration modules that shared between NixOS and MacOS.                                                |
| `nixos/*.nix`  | NixOS configuration modules. `home.nix` is a top-level home-manager module. `hardware-configuration.nix` is a hardware configuration and also encrypted by `git-crypt`. |
| `darwin/*.nix` | [nix-darwin](https://github.com/LnL7/nix-darwin) configuration modules. `home.nix` is a top-level home-manager module.                                                  |

The reposiory should be cloned into `nix` folder in the user's home folder.

## Setup on NixOS

Installation command:

``` shell
sudo nixos-rebuild switch --flake .
```

## Setup on MacOS

Install Nix and [homebrew](https://brew.sh/). Homebrew will be used only for installing casks. Then run the following command:

``` shell
nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake .
nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/master -- switch --flake .
```

## Common tasks

* formatting: `nix fmt`
* upgrade to new versions: `nix flake update`

