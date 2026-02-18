# Agent Guidelines for Nix Configuration

This repository contains NixOS and Home-Manager configurations for multiple computers. Read [README.md](./README.md) for structure overview.

## Build and Validation Commands

### Build Configuration
```bash
# Build specific host configuration
nix build .#nixosConfigurations."$HOST".config.system.build.toplevel

# Build home-manager configuration
nix build .#homeConfigurations."$USER@$HOST".activationPackage
```

### Validation
```bash
# Check all configurations (slow, use as final step)
nix flake check .#

# Format code
nix fmt

# Quick syntax check (faster than full check)
nix eval .#nixosConfigurations."$HOST".config.system.build.toplevel
```

### Git Operations
```bash
# Git uses GPG signing by default which requires password
# Always commit without signing:
git commit --no-gpg-sign -m "message"
```

## Code Style Guidelines

### File Organization
- **NixOS modules**: `modules/nixos/<name>/` with `default.nix` (imports & implementation on simple module), `options.nix` (options). The structure can be expended
- **Home-manager modules**: `modules/home-manager/<name>/` with `default.nix`
- **Configurations**: `configuration/<computer>/` for NixOS, `users/<user>/<computer>/` for Home-Manager
- **Common configs**: `configuration/commun/` and `users/<user>/commun/default.nix`

### Module Structure
```nix
# options.nix - Define options
{ lib, config, ... }:
with lib; {
  options.extra.<module> = {
    enable = mkEnableOption "<module>";
    # other options...
  };
}

# default.nix - Implement configuration
{ config, lib, ... }:
let cfg = config.extra.<module>;
in { 
  imports = [./options.nix];
  config = lib.mkIf cfg.enable {
    # configuration...
  };
}
```

### Naming Conventions
- All extra modules namespaced under `extra.*`
- `config.vars` reserved for cross-module variables
- Use descriptive names: `extra.containers`, `networking.traefik`
- Computer names from `computers.nix` (e.g., `dynas`, `vampire`)

### Formatting
- Use `nixfmt` (configured via treefmt-nix in `fmt.nix`)
- Run `nix fmt` before committing
- 2-space indentation (nixfmt default)
- Align attributes where readable

### Special Abstractions

#### Containers (`extra.containers`)
- High-level abstraction over NixOS containers
- Options: `vpn`, `gpu`, `privateNetwork`, `traefik`
- Auto-assigns IPs from `192.168.100.x` range (<- shoud not be exploited directly )
- See `modules/nixos/containers/README.md`

#### Traefik (`networking.traefik`)
- Reverse proxy configuration
- Integrates with containers for automatic routing
- Options: `enable`, `baseDomain`, `instances`, `log.level`
- See `modules/nixos/traefik/README.md`

### Secrets
- Use `sops-nix` for secrets requiring runtime access
    * see `.sops.yaml` for the configuration
- Use `git-crypt` for secrets only hidden from GitHub
    * encrypts anything that matches `**/secrets/**`.
- Use preferably `sops-nix` whenever possible, fall back to git crypt otherwise
- All secrets should be hidden by either `sops-nix` or `git crypt`

### Nixpkgs Channels
- `nixpkgs-stable`: NixOS 25.11
- `nixpkgs-unstable`: Unstable branch
- `nixpkgs-kernel`: Pinned kernel (Linux 6.17)
- Access via `pkgs`, `pkgs-stable`, `pkgs-unstable`, `pkgs-kernel`

### Testing
- No automated test suite - use `nix flake check` for validation
- Build specific host to test changes
- Test on non-production hosts first (e.g., `vampire` before `dynas`)
- Don't forget to `git add` new files before running any `nix` commands

### Commit Guidelines
- Use `git commit --no-gpg-sign` to avoid GPG password prompt
- Write concise commit messages
- Build and check before committing
- Format with `nix fmt` before committing