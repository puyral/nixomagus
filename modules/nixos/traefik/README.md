# Traefik Module

This module manages the Traefik reverse proxy configuration, offering both global settings and per-service instances. It tightly integrates with the [Containers Module](../containers/README.md) to automatically route traffic to containerized services.

## Global Configuration

Located under `networking.traefik`:

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `enable` | boolean | `false` | Enables the Traefik service. |
| `baseDomain` | string | `config.extra.acme.domain` | The default root domain for all services (e.g., `puyral.fr`). |
| `log.level` | enum | `"ERROR"` | Traefik log level (`INFO`, `DEBUG`, etc.). |
| `instances` | attrs | `{}` | Manual definition of reverse proxy instances (rarely used directly, prefer `extra.containers`). |

## Instance Configuration

These options define how a specific service is exposed. They can be used inside `networking.traefik.instances.<name>` or `extra.containers.<name>.traefik`.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `enable` | boolean | `false` | Enables this specific route. |
| `port` | port | **Required** | The internal port of the service. |
| `domain` | string | `null` | Overrides the global `baseDomain`. |
| `name` | string | container name | Subdomain name (e.g., `jellyfin` -> `jellyfin.puyral.fr`). |
| `container` | string | `null` | Name of the target container. Auto-filled when used within `extra.containers`. |
| `address` | string | `null` | Explicit IP address. If null, resolves to the container's `localAddress` or `localhost`. |
| `providers` | list\<str\> | `["dynas"]` | List of hostnames where this route should be active. |
| `extra.rule` | string | `null` | Custom Traefik rule (overrides default `Host(...)`). |

## Features

- **Automatic TLS**: Uses Let's Encrypt (via OVH DNS challenge) for all defined routers.
- **Dynamic Configuration**: Generates Traefik dynamic configuration files based on active instances on the current host.
- **Dashboard**: Available at `traefik.<host>.<domain>` (requires auth).
