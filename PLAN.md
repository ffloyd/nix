# NixOS Configuration Refactoring Plan

**First priority:**

- [x] fancy boot sequence
- [x] convinient workspace & window management
    - [x] distinct visual view for special workspaces
- [-] easy access to essential applications
    - [x] pass works
    - [x] Anytype works across reboots
        - [x] Keyring integration (GNOME Keyring)
    - [x] File Manager
    - [ ] Freemind
    - [ ] Proton Drive
    - [x] Spotify
    - [ ] Zeal
- [-] all hardware are usable
    - [ ] check if WiFi stable
    - [ ] camera
    - [ ] microphone
    - [x] power mode switching
        looks like is's working
    - [ ] closing lid suspends
    - [x] printer
    - [ ] hibernation

**Second priority:**

- [x] adjusted & easy-to-extend topbar
- [x] adjust all to similar look & feel

**Third priority:**

- [x] screenshots
- [ ] screen recording
- [ ] investigate WiFi stability issues
- [ ] clipboard manager
- [ ] gaming (heroic, playnite)
- [x] adjusted & easy-to-extend app launcher
- [ ] local LLM execution
- [x] system monitoring (good UI, GPU support)
- [ ] copy-paste from phone to PC
- [ ] secrets management with sops-nix
    - consider how to apply on fresh system
    - consider some safe solution based on git-crypt
- [ ] Personal Wireguard server setup
- [x] LLM usage tracking (how much money spent on LLMs)
    I did it for ClaudeCode and I mostly use it

**Small Issues Backlog:**

- [x] identify what was causing CUPS to be extremely slow
    Most probably, it was the printer discovery process, pdd generation
- [ ] Fix Qt theme issues (zeal & kate should look fine with the theme)
- [ ] printer management UI with ink levels
- [ ] sometimes Plymouth does not show up
- [ ] logging off breakes] Claude SDDM
- [ ] audio output is not controllable until first sound is played after boot
