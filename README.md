# NixOS + macOS + NeoVim Configuration

Personal dotfiles and system configurations managed with Nix flakes.

__Note:__ I switched to dendritic pattern recently.
From implementation perspective it's functional and already convinient, but I still need to re-arrange some configurations and still experimenting with granularity.

## What this repo is

This repository contains my personal configurations for NixOS and macOS machines.
It is done as a [Nix flake](https://nixos.wiki/wiki/Flakes) which implements a top-level orchestrator for all my organized configurations and tools.


| Path | |
| --- | --- |
| [flake.nix](flake.nix) | Entry point that wires everything together and defines flake outputs. |
| [my/](my) | All custom options and helper modules, all namespaced under `my.*`. |
| [aspects/](aspects) | Feature bundles: groups of NixOS, Darwin, and shared modules. |
| [hosts/](hosts) | Per-machine definitions and host-specific modules. |
| [dotfiles/](dotfiles) | Files that are symlinked directly into the home directory. |
| [dotfiles/nvim](dotfiles/nvim) | NeoVim configuration. |


## If you are new to Nix

If you are just curious about Nix, this repo might look a bit dense at first, and that is normal.
As an entry point to the Nix ecosystem, I recommend to check out the following resources:

- [Official Nix(OS) website](https://nixos.org/) - for general information about Nix and NixOS.
- [Vimjoyer Youtube channel](https://www.youtube.com/@vimjoyer) - this guy is amazing at explaining Nix and NixOS concepts in a very approachable and practical way. His channel was my entry point to Nix and I _highly_ recommend it.
- Understanding of the following tools is essential to understand this repo. Also check related Vimjoyer's videos. 
    - [flake.parts](https://flake.parts)
    - [Home Manager](https://github.com/nix-community/home-manager)
    - [nix-darwin](https://github.com/LnL7/nix-darwin)

## Why Nix?

Now I can do "ASDF peasants" jokes.

On a more serious note, well... it's a toolkit that 

- can manage dotfiles
- supports both Linux and macOS
- allows you to configure your system declaratively
- makes reverting any changes as easy as reverting a commit
- replaces [ASDF](https://asdf-vm.com/), [mise](https://mise.jdx.dev/) and similar "dev shell" tools. Provides reproducibility, not just replayability. 
- can be used to define and build Docker images (and they will be reproducible, not just replayable like with Dockerfiles)
- and more

Just a single toolkit.
While ASDF, homebrew, and other tools I mentioned much simpler and easier to use, they underperform in many aspects in comparison to Nix.
One I mentioned here is the _reproducibility_ vs _replayability_.
Let me explain on example of a Dockerfile.
When you have line like `RUN apt-get update && apt-get install -y nodejs` in your Dockerfile, it will install the latest version of nodejs at the moment of building the image.
This is replayable, but not reproducible, because the same Dockerfile can produce different outputs at different times.
It's only the tip of the iceberg, Dockerfiles are not designed for reproducibility in general and have non-deterministic nature.
Like ASDF, like mise, and many other popular tools.

It's ok for many contexts to not have those strong guarantees and take some risks in exchange for simplicity.
But personally, I prefer to master complex toolkit that is _fun to learn_, rather than waste time on simpler but boring tasks like fixing broken ASDF shims, dealing with Homebrew's quirks after system upgrade, and similar.
With Nix such issues are less likely to happen, and when they do, they are usually easier and _more comfortable_ to fix.
Moreover, Nix has a massive amount of interesting engineering decisions to learn from and become better engineer.

In the end, I may not save a lot of time with Nix - it takes time to learn and Nix is pretty complex.
In exchange, I avoid _a lot_ of frustration and have _a lot_ of fun in the process.
After all, let be honest - we do things not for efficiency, _satisfaction_ is what we are really after, and Nix is a very satisfying tool to master.
Like Vim, Emacs, Terraform - I have similar experience with them.

## Setup on NixOS

The repository should be cloned into the `nix` folder in the user's home directory.

Installation command (in the root folder of the repository):

``` shell
sudo nixos-rebuild switch --flake .
```

## Setup on macOS

The repository should be cloned into the `nix` folder in the user's home directory.

Install Nix and [Homebrew](https://brew.sh/). Then run the following command in the root folder of the repository:

``` shell
nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake .
nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/master -- switch --flake .
```

## Configuration Philosophy

This configuration leans toward an objective-based organization approach instead of a more traditional category-based organization.
Rather than grouping configurations by technical category (LSP, UI, Git tools), modules are organized around specific objectives or goals.

When it makes sense, each feature module's naming and documentation focus on what it needs to achieve rather than what technology it uses.
This approach is inspired by OKR (Objectives and Key Results) methodology, adapted for configuration management.
The same philosophy drives both the Neovim configuration and the Nix module structure.

It helps me stay focused on the end goals and avoid concentrating too much on technical details.

_**Not every module here strictly follows this philosophy and it's by design.**
If you have done OKRs, you would understand that defining good objectives is hard and often takes a lot of time and practice.
While it forces you to ask yourself "why" more often, sometimes it's just better to put something in a separate file without overthinking._

## Architecture

Over time I designed or adopted various concepts to organize configurations.

### flake.parts and dendritic pattern

I was truly impressed by the idea of a [dendritic pattern](https://github.com/mightyiam/dendritic).
TL;DR: it is about shifting from:

> Each Nix file structure is defined by its caller.
> You need to understand where a file is used to understand how to read it.
> Shared values are passed via `specialArgs` and `imports`.

to something less cognitively demanding:

> Each Nix file except for `flake.nix` is a [flake.parts](https://flake.parts) module.
> Knowing what flake.parts is and how it works is enough to understand the structure of any file in the repository.
> You can directly access any value from any other module.

It also allows all Nix files to be merged together automatically using [import-tree](https://github.com/vic/import-tree) instead of manually importing each file.

### Oh `my`

I had to go beyond standard flake.parts capabilities.
All Nix files that implement custom options and their behavior are located in the `my/` folder.
All custom options are prefixed with `my.` to avoid potential conflicts with options from other flake.parts modules.

### Aspects and hosts

Simply speaking, main building blocks of the configuration are:

- [NixOS modules](https://nixos.wiki/wiki/NixOS_modules) - for NixOS system-level configuration.
- [nix-darwin](https://github.com/LnL7/nix-darwin) modules - for macOS system-level configurations.
- [home-manager](https://github.com/nix-community/home-manager) modules - for user-level configurations and for shared modules that work both for NixOS and macOS.

While for one host it would be ok to define those modules and import them into one machine configuration, I have multiple machines and their module sets are not identical.
So I introduced `my.hosts` and `my.aspects` options.

**Aspect** is a collection of NixOS, nix-darwin, and home-manager modules that together implement a specific feature set.

**Host** is a concrete machine definition that I use, with its hostname, username, system type, and list of aspects that should be enabled on it.

Actual machine configurations are generated from host definitions and aspects.
See `my/hosts.nix` and `my/aspects.nix` for options documentation and implementation details.

The `aspects/` folder contains aspect definitions. Each aspect is either a single file or a folder with multiple files.

The `hosts/` folder contains host definitions (`hosts/host-alias.nix`) and host-specific modules (`hosts/host-alias/*.nix`).

### Shared constants and private data

`my.consts` is a loosely typed attrset that serves as a container for global constants.
flake.parts makes it available for any Nix file.
Its main use case is sensitive data I do not want to share publicly, such as email addresses and similar.
So I set them in `private.nix`, which is encrypted using [git-crypt](https://www.agwa.name/projects/git-crypt/).

For example, `my.consts.personalEmail` is convenient because personal email is used in many places and does not belong to a single aspect.
But I do not want to expose it openly for web crawlers and similar, so I keep it in `private.nix` and encrypt it with git-crypt.

The `hosts/*/hardware-configuration.nix` files are another example of files I have encrypted with git-crypt.
They are host-specific modules and unrelated to `my.consts`, but they contain serial numbers and other sensitive hardware data I do not want to expose.

### Helpers

Nix has an impressive standard library, but sometimes I need specific functions that are not available there.
When possible, I keep them module-local.
For the rest, I have `my.helpers` - a collection of helper functions that are used across different modules and aspects.
Check `my/helpers.nix` for details.

### Directly symlinked dotfiles

Configuration files generated by Nix are immutable.
Updating them requires re-evaluating the configuration, which takes 10-30 seconds on my machines.
While it is ok or even beneficial for most of my cases, it is not ideal for dotfiles that I edit often or need a faster feedback loop for.

Good examples are AI-related files, Neovim configuration, and terminal configuration.

I made `my.helpers.mkOutOfStoreSymlink`, which is used to create symlinks to dotfiles directly from the repository to the home directory, bypassing the Nix store.
This allows editing dotfiles in place like in good old times, no need to wait for Nix to re-evaluate and re-generate them.

### Ahead-of-time packages

For cases when recent `nixpkgs` has some problem that blocks a full system upgrade, but I need a newer version of some package, I introduced `pkgs-aot` to access newer package versions selectively.

It is a second `nixpkgs` flake input that can be updated independently and available as `pkgs-aot` in any NixOS/home-manager/nix-darwin module.
I can update this input independently from the main `nixpkgs` and use it for specific packages that I need to be newer than those in the main `nixpkgs`.

```nix
{ pkgs, pkgs-aot, ... }:
{
  environment.systemPackages = [
    pkgs.firefox         # from main nixpkgs
    pkgs-aot.neovim      # newer version with isolated dependencies (from nixpkgs-aot)
  ];
}
```

## Common tasks

### Maintenance

* Format code: `nix fmt .`
* Check flake validity: `nix flake check --all-systems`
* Upgrade dependencies: `nix flake update`
* Upgrade specific input: `nix flake update nixpkgs-aot`

### Validation & Testing (NixOS)

* Test if configuration builds: `nixos-rebuild dry-build --flake .`
* Preview activation changes: `nixos-rebuild dry-activate --flake .`
* Lint: `statix check`

### Applying Changes

See aliases in `./aspects/base/nix.nix`.
