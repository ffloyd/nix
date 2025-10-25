# Design: nixpkgs-aot Input

## Context

Nix flakes use `flake.lock` to pin all inputs to specific commits for reproducibility. When using `nixos-unstable`, build failures in some packages can block full system upgrade. However, many other packages build successfully and would be useful at their latest versions.

The current workaround is either:
1. Wait for all build issues to be resolved
2. Use overlays with manual package overrides

Those approaches are annoying when I only want to update a single package and don't want to be distracted from what I'm doing.

## Goals / Non-Goals

**Goals:**
- Allow selective access to packages from a newer nixpkgs commit
- Maintain reproducibility through flake.lock
- Keep the implementation simple and maintainable
- Complete isolation between `pkgs` and `pkgs-aot` to avoid conflicts

**Non-Goals:**
- Automatic detection of which packages should come from aot
- Sophisticated version management or conflict resolution
- Supporting multiple different nixpkgs versions simultaneously (only two: main and aot)
- Backporting or cherry-picking specific package updates

## Decisions

### Use a separate flake input

**Decision:** Add `nixpkgs-aot` as a separate top-level flake input rather than using git submodules, overlays from other sources, or manual package expressions.

**Rationale:**
- Flake inputs are already the standard mechanism for external dependencies
- `flake.lock` provides automatic version pinning and reproducibility
- `nix flake update` commands already understand how to update specific inputs
- Pattern is familiar to anyone working with Nix flakes

**Alternatives considered:**
- Overlays from external flakes: More complex, requires additional input management
- Git submodules: Breaks Nix's reproducibility model, requires manual updates
- Per-package overrides: Doesn't scale, loses the "use latest" intent

### Use separate parameter for complete isolation

**Decision:** Implement `nixpkgs-aot` access through a separate `pkgs-aot` parameter passed to all modules via `specialArgs` and `extraSpecialArgs`.

**Rationale:**
- Complete isolation prevents any potential conflicts between package sets
- Explicit parameter makes it clear when AOT packages are being used
- No risk of accidentally mixing packages from different nixpkgs versions
- Clean separation of concerns: `pkgs` for stable, `pkgs-aot` for ahead-of-time
- Works consistently across NixOS, Home Manager, and nix-darwin

**Alternatives considered:**
- Overlay with `pkgs.aot` attribute: Mixes both package sets in single parameter, potential for conflicts
- Top-level flake attribute: Doesn't integrate with existing module evaluation
- Package aliases: Confusing which version is being used

### Share configuration between nixpkgs and nixpkgs-aot

**Decision:** Apply the same configuration (allowUnfree, system architecture, etc.) to both `nixpkgs` and `nixpkgs-aot` imports.

**Rationale:**
- User expects consistent behavior (e.g., if unfree is allowed, it should work for both)
- Reduces configuration duplication and potential for drift
- Simplifies mental model: "same configuration, different versions"

**Alternatives considered:**
- Separate configuration: Could allow different settings, but adds complexity and potential for confusion

### Add pkgs-aot to common context

**Decision:** Add `pkgs-aot` to `commonContext` so it's automatically available to all modules via specialArgs/extraSpecialArgs.

**Rationale:**
- Common context is already used to pass shared values (globals, private, helpers) to all modules
- Avoids repetition in nixosSystem and macosSystem functions
- Ensures consistent availability across NixOS, Home Manager, and nix-darwin
- Since both NixOS and Home Manager receive common context, adding it once makes it available everywhere

**Alternatives considered:**
- Passing separately in each system builder: More repetitive, but considered during initial design

## Implementation Approach

1. **Input declaration** (flake.nix inputs section):
   ```nix
   nixpkgs-aot.url = "github:NixOS/nixpkgs/nixos-unstable";
   ```

2. **Package set creation** (add to commonContext):
   ```nix
   # For NixOS (x86_64-linux)
   pkgs-aot = import inputs.nixpkgs-aot {
     system = "x86_64-linux";
     config.allowUnfree = true;
   };
   
   # For macOS (aarch64-darwin)
   pkgs-aot = import inputs.nixpkgs-aot {
     localSystem = "aarch64-darwin";
     config.allowUnfree = true;
   };
   
   # Add to common context
   commonContext = {
     inherit inputs globals private mkDotfilesLink ...;
     inherit pkgs-aot;
   };
   ```

3. **Automatic availability via existing context propagation**:
   ```nix
   # NixOS modules receive it via specialArgs
   specialArgs = context;
   
   # Home Manager modules receive it via extraSpecialArgs
   extraSpecialArgs = context;
   ```

4. **Usage in modules**:
   ```nix
   { pkgs, pkgs-aot, ... }: {
     environment.systemPackages = [ 
       pkgs.somePackage      # from main nixpkgs
       pkgs-aot.newerPackage # from nixpkgs-aot
     ];
   }
   ```

## Risks / Trade-offs

### Risk: Dependency isolation and potential conflicts

Packages from `pkgs-aot` use dependencies exclusively from `nixpkgs-aot`, creating a completely separate dependency tree. This means a package from `pkgs-aot` might depend on different versions of system libraries than those in the base system.

**Mitigation:**
- Use `nixpkgs-aot` primarily for self-contained applications rather than libraries
- Avoid mixing `pkgs` and `pkgs-aot` packages that need to interoperate at runtime
- Test configurations with `nixos-rebuild dry-build` before applying
- Document that `pkgs-aot` creates an isolated dependency tree
- When in doubt, prefer using `pkgs`. `pkgs-aot` is for specific cases where newer versions has significant benefits and full upgrade is not possible.

### Risk: Confusion about package sources

Users might forget which packages come from which input.

**Mitigation:**
- Separate `pkgs-aot` parameter makes the source explicit
- Module signatures clearly show when AOT packages are available
- Document in README when to use `pkgs-aot.*` vs `pkgs.*`
- Both inputs point to same branch initially, reducing cognitive load

### Trade-off: Lock file size

Adding another input increases `flake.lock` size and evaluation overhead.

**Impact:**
- Minimal: lock file already contains multiple inputs
- Evaluation overhead negligible compared to build time
- Acceptable for the functionality gained

## Migration Plan

No migration needed - this is a purely additive change:

1. Add input and overlay mechanism
2. Both `nixpkgs` and `nixpkgs-aot` initially point to same commit
3. Users can begin using `pkgs.aot.*` when needed
4. Existing configurations continue working unchanged

## Open Questions

None - implementation is straightforward and well-understood.
