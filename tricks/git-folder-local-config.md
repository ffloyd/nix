# Per-directory Git Identity

Git supports conditional configuration includes.
This lets you apply different settings depending on where a repository is located on disk.

## How It Works (Git)

Git's `includeIf` directive evaluates a condition and, when it matches, loads another config file.
The `gitdir` condition checks the repository's location:

```gitconfig
# ~/.gitconfig
[includeIf "gitdir:~/Work/"]
  path = ~/.gitconfig-work
```

```gitconfig
# ~/.gitconfig-work
[user]
  email = "work@example.com"
  signingkey = "DEADBEEF"
[commit]
  gpgsign = true
[tag]
  gpgsign = true
```

Any repo under `~/Work/` will use the work identity.
Repos elsewhere use the default identity from `~/.gitconfig`.

- `gitdir:` matches on the path to the `.git` directory of the repo.
- `gitdir/i:` is the case-insensitive variant.
- `onboarding:` matches the current branch name.
- Also supports `hasconfig:remote.*.url:` for remote-based conditions.

This is useful when you have both personal and work repos on the same machine and need different commit authorship / signing keys per context.

## How to use with Nix Home Manager

With `programs.git.includes`, you declare the conditional config directly:

```nix
programs.git.includes = [
  {
    condition = "gitdir:~/Work/";
    contents = {
      user = {
        email = "work@example.com";
        signingkey = "DEADBEEF";
      };
      commit.gpgSign = true;
      tag.gpgSign = true;
    };
  }
];
```

Home Manager generates the included file in the Nix store and wires up the `includeIf` in `~/.gitconfig` automatically.

### Different SSH Keys per Directory

When you use separate SSH keys for personal and work remotes, you need Git to pick the right key depending on the repo's location.

With conditional includes, you can set a per-directory `sshCommand`:

```nix
programs.git.includes = [
  {
    condition = "gitdir:~/Work/";
    contents = {
      core.sshCommand = "ssh -i ~/.ssh/id_work";
    };
  }
];
```
