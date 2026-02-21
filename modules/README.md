# Modules

This directory contains reusable NixOS and Home Manager modules for this repository.

## Structure

```
modules/
├── nixos/                    # NixOS system modules
│   ├── default.nix           # Full aggregator
│   ├── nixos-modules.nix     # Flake exports
│   ├── containers/           # Container abstraction
│   ├── traefik/             # Reverse proxy
│   └── ... (40+ modules)
├── home-manager/             # Home Manager user modules
│   ├── default.nix           # Full aggregator
│   ├── home-manager-modules.nix  # Flake exports
│   ├── emacs/               # Emacs configuration
│   ├── sway/                # Wayland compositor
│   └── ... (30+ modules)
├── commun/                   # Modules compatible with both NixOS & Home Manager
│   ├── default.nix
│   └── tailscale/
└── REFACTOR_NOTES.md         # Technical debt documentation
```

## Flake Exports

Modules are exported as flake outputs at the repository level (in `flake.nix`):

### NixOS Modules

```bash
nixosModules.default          # Full module aggregator (all modules)
nixosModules.acme             # Individual ACme module
nixosModules.containers       # Container abstraction
nixosModules.traefik          # Traefik reverse proxy
# ... 40+ more
```

### Home Manager Modules

```bash
homeManagerModules.default    # Full module aggregator (all modules)
homeManagerModules.emacs      # Emacs configuration
homeManagerModules.sway       # Wayland compositor
# ... 30+ more
```

## Usage

### Using the Full Aggregator

The aggregator (`default`) includes all modules and imports them in the correct order. This is the recommended approach for most configurations.

In NixOS configurations (now uses `self.nixosModules.default` in `lib/default.nix`):
```nix
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default  # All NixOS modules
    # ... other modules
  ];
}
```

In Home Manager configurations (uses `./modules/home-manager` relative path in `home_manager.nix`):
```nix
{
  imports = [
    ./modules/home-manager  # All Home Manager modules
    # ... other modules
  ];
}
```

### Using Individual Modules

For more control, you can import specific modules:

```nix
{
  imports = [
    self.nixosModules.traefik
    self.homeManagerModules.emacs
  ];
}
```

## Commun Modules

Modules in `modules/commun/` work with both NixOS and Home Manager. They are:

1. Imported by both `modules/nixos/default.nix` and `modules/home-manager/default.nix`
2. Available as both `nixosModules.commun` and `homeManagerModules.commun` when accessed individually

This duplication pattern allows commun modules to be used in both contexts without creating symbolic links or complex import logic.

## Creating New Modules

### NixOS Module

1. Create directory `modules/nixos/your-module/`
2. Add `default.nix` with your module:
   ```nix
   { config, lib, ... }:
   {
     options.extra.your-module.enable = lib.mkEnableOption "your-module";
     config = lib.mkIf config.extra.your-module.enable {
       # your configuration
     };
   }
   ```
3. Add import to `modules/nixos/default.nix`
4. Add entry to `modules/nixos/nixos-modules.nix`

### Home Manager Module

1. Create directory `modules/home-manager/your-module/`
2. Add `default.nix` with your module
3. Add import to `modules/home-manager/default.nix`
4. Add entry to `modules/home-manager/home-manager-modules.nix`

### Commun Module

1. Create directory `modules/commun/your-module/`
2. Add `default.nix` with your module
3. Add import to `modules/commun/default.nix`
4. Add imports to both `modules/nixos/default.nix` and `modules/home-manager/default.nix`
5. Add entry to both `nixos-modules.nix` and `home-manager-modules.nix`

### Module Conventions

- All module options should be namespaced under `extra.*` (e.g., `extra.your-module.enable`)
- Simple modules can be a single `default.nix` file
- Complex modules can use multiple files:
  ```
  your-module/
  ├── default.nix      # Implementation
  ├── options.nix      # Option definitions
  └── README.md        # Documentation
  ```
- For modules that need external resources (secrets, files), these should be handled via `sops-nix` or proper path parameters

## Technical Notes

### Refactoring History

The modules were recently refactored to be exported as flake outputs. See `REFACTOR_NOTES.md` for:

- Details on the removal of `rootDir` path dependencies
- Sketchy patterns that remain and how to clean them up
- Migration considerations for the future

### Module Evaluation

Modules are evaluated lazily - they're only evaluated when a configuration actually uses them. This makes the flake fast to evaluate even with many modules.

### Special Arguments

Modules receive special arguments including:
- `pkgs` - Package set
- `lib` - Nixpkgs library
- `config` - Current configuration (for referencing other module values)

Some modules also expect:
- `rootDir` - Repository root path (see REFACTOR_NOTES.md)
- `inputs` - Flake inputs
- `self` - The flake itself

## Available Modules

### NixOS Modules (43)

- `acme` - ACME certificate management
- `authelia`, `authentik` - Authentication systems
- `binary-cache` - Nix binary caching
- `bitwarden` - Password manager integration
- `cachefilesd` - Caching filesystem daemon
- `calibre-web` - E-book management
- `containers` - High-level container abstraction
- `controllers` - Hardware controllers
- `docker-traefik`, `traefik` - Reverse proxy
- `fileflows` - Media processing
- `github-runner` - GitHub Actions runner
- `gui` - GUI frameworks (GNOME, Hyprland, i3, Sway)
- `headscale` - Tailscale coordination server
- `immich`, `kavita`, `photoprism` - Photo/media management
- `llm` - Language model tools
- `mail`, `mail-server`, `simple-nixos-mailserver` - Email
- `monitoring` - System monitoring
- `mount-containers` - Container volume mounting
- `n8n` - Workflow automation
- `nix-ld` - Library loader for non-NixOS binaries
- `ntfy` - Notification service
- `paperless` - Document management
- `printing` - Printer configuration
- `refind` - EFI boot manager
- `smartd` - SMART monitoring
- `splashscreen` - Boot splash
- `syncthing-module` - File synchronization
- `tailscale`, `tailscale-exit-container` - VPN
- `torrent` - Torrent clients
- `v4l2loopback` - Video loopback device
- `vaultwarden` - Unofficial Bitwarden server
- `virtualisation` - Virtualization settings
- `wachtower` - Watchtower (image updates)
- `zigbee2mqtt` - Zigbee bridge
- And container-specific modules

### Home Manager Modules (31)

- `alacritty` - Terminal emulator
- `applications` - General applications
- `btop` - System monitor
- `darktable` - Photo editing
- `emacs` - Text editor
- `firefox` - Web browser
- `git`, `git-config-fetcher`, `lazygit` - Git tools
- `hyprland`, `i3`, `sway` - Window managers
- `keyring` - Keyring management
- `logseq` - Note-taking
- `ntfy` - Notifications
- `opencode` - AI assistant
- `shell`, `starship`, `zsh` - Shell
- `sops` - Secrets management
- `ssh` - SSH configuration
- `systemd-services` - User services
- `tmux` - Terminal multiplexer
- `vscode` - Code editor
- `wandarr` - Media management
- `wallpaper` - Wallpaper setter
- `xkb` - Keyboard layout
- `yazi` - File manager

## Further Reading

- [AGENTS.md](../AGENTS.md) - Repository-wide conventions and build/test commands
- [flake.nix](../flake.nix) - Main flake definition
- [lib/default.nix](../lib/default.nix) - Configuration orchestration
- [REFACTOR_NOTES.md](REFACTOR_NOTES.md) - Technical debt and future improvements