# Refactoring Notes: Modules as Flake Outputs

This file documents technical debt and areas that could be improved after the modules-to-flake-parts refactoring.

## rootDir Usage

The `rootDir` variable is currently used throughout the codebase to reference the repository root path via string concatenation. This is problematic because:

1. **Hardcoded path dependencies**: It creates hidden dependencies on the flake file structure
2. **Non-idiomatic Nix**: Using string concatenation for paths breaks Nix's purity model
3. **Limited portability**: Changes to repository structure require updating multiple files

### Current Usage Locations

`rootDir` is still referenced in the following files:

#### Configuration Files
- `configuration/commun/default.nix:137` - SSH keys import
- `configuration/commun/services/zerotierone.nix:7` - zerotier networks
- `configuration/i7/default.nix:6` - jellyfin overlay
- `configuration/mydos/default.nix:10` - jellyfin overlay
- `configuration/dynas/zfs.nix:3` - unused parameter
- `configuration/amdra/zfs.nix:3` - unused parameter

#### Module Files (NixOS)
- `modules/nixos/containers/default.nix:7,44,93`
- `modules/nixos/traefik/static.nix:2,42`
- `modules/nixos/smartd/default.nix:4` - unused
- `modules/nixos/sops/default.nix:4` - unused
- `modules/nixos/authentik/default.nix:10,88`
- `modules/nixos/authelia/secrets/email.nix:1,6`

#### Module Files (Home Manager)
- `modules/home-manager/ssh/default.nix:3,23`
- `users/all/default.nix:2,11`
- `users/simon/i7/default.nix:10` - pattern matching...
- `users/simon/mydos/default.nix:10` - pattern matching...

#### Other
- `lib/default.nix:1,89,110,133,134,135,174,186` - orchestrator imports
- `packages/doc/default.nix:3,12,15,40`

### Proposed Solution

Replace `rootDir` usage with alternatives:

1. **For secrets**: Use `sops-nix` with proper file paths via `config.sops.secrets`
2. **For overlays**: Pass overlays as parameters or use ` overlays = []` in configuration
3. **For paths to other modules**: Use the newly exported flake outputs (`self.nixosModules.*`, `self.homeManagerModules.*`)
4. **For registeries**: Hardcode expected paths or move to nix registry

### Example Migration Pattern

```nix
# Before (sketchy - requires rootDir):
{ rootDir, ... }:
{
  config = import (rootDir + /secrets/email.nix);
}

# After (clean):
{ config, ... }:
let
  emailSecret = config.sops.defaultSopsFile + "/email/email.nix";
in
{
  # Access secrets via sops-nix attributes
}
```

## Module References

The modules are now exported as flake outputs:

- `nixosModules.default` - Full NixOS module aggregator
- `nixosModules.<name>` - Individual NixOS module
- `homeManagerModules.default` - Full Home Manager module aggregator
- `homeManagerModules.<name>` - Individual Home Manager module

These can be referenced in configurations using `self.nixosModules.*` and `self.homeManagerModules.*` within the flake scope.

## Commits Related to This Refactoring

See git log for the changes made during this refactoring.