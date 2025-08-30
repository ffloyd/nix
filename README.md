# NixOS + macOS Configuration

Personal dotfiles and system configurations managed with Nix flakes.

## Overview

This repository contains my personal configurations for NixOS and macOS machines.
It uses [Nix flakes](https://nixos.wiki/wiki/Flakes) to provide reproducible system configurations for:

- [Framework laptop](https://frame.work/de/en) running NixOS with Hyprland
- Desktop machine running NixOS
- Work MacBook with nix-darwin

The repository includes an extensive Neovim configuration (~30% of all config lines) with AI integrations.

## Architecture

Standard NixOS modules are used for NixOS configuration.
[home-manager](https://github.com/nix-community/home-manager) is used for user-level configurations and for sharing modules between NixOS and macOS.
[nix-darwin](https://github.com/LnL7/nix-darwin) is used for macOS system-level configurations.

Home Manager's `mkOutOfStoreSymlink` is used to directly link dotfiles from the repository to the home directory bypassing the Nix store.
This allows editing dotfiles in place without creating a new generation for each change.

Sensitive data is stored in `private.nix` and `hardware-configuration.nix` files, which are encrypted using [git-crypt](https://www.agwa.name/projects/git-crypt/).

As an output, the flake provides configurations for several machines.
Each machine has a different set of modules enabled.

NixOS hosts use merged configuration that includes both NixOS and Home Manager modules at the same time.
MacOS hosts use separate configurations for nix-darwin and Home Manager: I change nix-darwin configuration much less frequently, so there is no point to wait for additional 10+ seconds when updating Home Manager part.

## Repository structure


| Files          | Purpose                                                                                                                                                                 |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `flake.nix`    | The main entry point, defines configuration for all hosts.                                                                                                              |
| `globals.nix`  | An attrs set with some global values. Propogated to all modules.                                                                                                        |
| `private.nix`  | An attrs set with some global values that are personal data. Encrypted. Propogated to all modules.                                                         |
| `hosts/*`      | Each host has a folder with machine-specific configuration. `hardware-configuration.nix` is a hardware configuration and also encrypted. |
| `hm/*.nix`     |  Configuration modules that shared between NixOS and MacOS.                                                  |
| `nixos/*.nix`  | NixOS configuration modules. Can include home-manager configurations that are NixOS-specific. |
| `darwin/*.nix` | nix-darwin configuration modules. |
| `dotfiles/*`   | These files are linked directly, not through Nix store. It allows to edit them in place without creating a new generation for each change.                              |

## Setup on NixOS

The reposiory should be cloned into `nix` folder in the user's home folder.

Installation command (in the root folder of the repository):

``` shell
sudo nixos-rebuild switch --flake .
```

## Setup on MacOS

The reposiory should be cloned into `nix` folder in the user's home folder.

Install Nix and [homebrew](https://brew.sh/). Homebrew will be used only for installing casks. Then run the following command in the root folder of the repository:

``` shell
nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake .
nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/master -- switch --flake .
```

## Configuration Philosophy

This configuration uses an objective-based organization approach instead of more traditional category-based organization. Rather than grouping configurations by technical category (LSP, UI, Git tools), modules are organized around specific objectives or goals.

Each module focuses on what you want to achieve rather than what technology it uses. This approach is inspired by OKR (Objectives and Key Results) methodology, adapted for configuration management. The same philosophy drives both the Neovim configuration and the Nix module structure.

On practice, nix module files are named after the objective/goal they designed to achieve and start with a comment explaining the objective.
Each nix module may contain many sub-modules that implement technical features needed to achieve the objective.
So, it's ok to comment a sub-module with "setup hyprland", but the file with it should be about "desktop environment setup"/`desktop.nix` (which explains reason we need hyprland) and not "hyprland configuration"/`hyprland.nix`.

It helps me to stay focused on the end goals and avoid concentrating too much on technical details.

_**Not an every module here strictly follows this philosophy and it's by design.**
If you did OKR, you would understand that defining good objectives is hard and often takes a lot of time and practice.
While it forces to ask yourself "why" more often, sometimes it's just easier to put something in a separate file without overthinking._

## Common Nix Patterns

**Define module as a set of small sub-modules**

Following defined configuration philosophy, I want each module to be a set of small sub-modules, each responsible for a specific feature.
While the top-level module in a file is responsible for a specific objective, it may include multiple sub-modules that implement the technical details needed to achieve that objective.
The benefit of this approach is that for every option, I can easily say which technical feature it belongs to and which higher-level objective it helps to achieve.

Every Nix module (NixOS, home-manager, nix-darwin) has `imports` attribute that can be used to include other modules.
But also it can consume "inline" sub-modules:

```nix
{...}:
{
  imports = [
    # include other file
    ./submodule1.nix

    # inline sub-module
    {
      options.bla-bla.enable = true;
    }
  };
}
```

I cannot just split configuration using comments because Nix by default forbids duplicate keys in an attrs set:

```nix
{
  #
  # Feature A
  #
  # utils for feature A
  home.pkgs = with pkgs; [ pkgA pkgB ];

  # ...

  #
  # Feature B
  #
  # utils for feature B
  home.pkgs = with pkgs; [ pkgC pkgD ]; # <-- error: duplicate key
}
```

Such behavior is inconvenient when you want to split a module into smaller isolated parts each responsible for a specific feature.
`mkMerge` function from `nixpkgs.lib` can also be used to merge multiple attrs sets into one, but it has some critical limitations (cannot merge modules that define options or imports).


## Common tasks

* formatting: `nix fmt`
* upgrade to new versions: `nix flake update`
