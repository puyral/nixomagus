# NixOS Containers Abstraction

This module provides a high-level abstraction over standard NixOS containers, designed to simplify the deployment of services with common requirements like GPU access, VPN connectivity, and reverse proxy integration.

## Configuration

The main entry point is `extra.containers.<name>`.

### Options

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `vpn` | boolean | `false` | Enables Tailscale inside the container for VPN access. |
| `gpu` | boolean | `false` | Passes through `/dev/dri/renderD128` and installs Intel compute/media drivers (OpenCL, QSV) inside the container. |
| `privateNetwork` | boolean | `true` | Creates a private network (VEPA-like) with automatic IP assignment (`192.168.100.x`). If false, uses host networking. |
| `traefik` | list | `[]` | List of reverse proxy configurations. See [Traefik Module](../traefik/README.md). |

## Internal Mechanics

### Base Configuration
All containers inherit from `base_config.nix`, which provides:
- **Common Packages**: `vim`, `wget`, `htop`, `git`, `tmux`, `iptables`.
- **Networking Fixes**: Workaround for systemd-resolved bugs in containers.
- **SSH**: Enabled by default.
- **Nix Configuration**: Flakes enabled, unfree allowed, overlays applied from host.
- **Journald Upload**: Logs are uploaded to the host's journald.

### Networking
- **IP Assignment**: Automatically assigns IPs starting from `192.168.100.2` based on the container's index in the configuration.
- **NAT**: Configures `networking.nat` on the host to allow container internet access.
- **Firewall**: automatically opens necessary ports on the host for internal container communication if needed.

## Example Usage

```nix
extra.containers.my-service = {
  gpu = true;
  vpn = false;
  traefik = [
    {
      port = 8080;
      name = "myservice"; # becomes myservice.puyral.fr
      enable = true;
      providers = [ "my-host" ];
    }
  ];
};

containers.my-service = {
  bindMounts = { ... };
  config = { ... }; # Standard NixOS container config
};
```
