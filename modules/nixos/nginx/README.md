# Nginx Module

This module manages the Nginx reverse proxy configuration, offering both global settings and per-service instances. It tightly integrates with the [Containers Module](../containers/README.md) to automatically route traffic to containerized services.

## Global Configuration

Located under `networking.nginx`:

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `enable` | boolean | `false` | Enables the Nginx service. |
| `baseDomain` | string | `config.extra.acme.domain` | The default root domain for all services (e.g., `puyral.fr`). |
| `instances` | attrs | `{}` | Manual definition of reverse proxy instances (rarely used directly, prefer `extra.containers`). |

## Instance Configuration

These options define how a specific service is exposed. They can be used inside `networking.nginx.instances.<name>` or `extra.containers.<name>.nginx`.

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `enable` | boolean | `false` | Enables this specific route. |
| `port` | port | **Required** | The internal port of the service. |
| `domain` | string | `null` | Overrides the global `baseDomain`. |
| `name` | string | container name | Subdomain name (e.g., `jellyfin` -> `jellyfin.puyral.fr`). |
| `container` | string | `null` | Name of the target container. Auto-filled when used within `extra.containers`. |
| `address` | string | `null` | Explicit IP address. If null, resolves to the container's `localAddress` or `localhost`. |
| `providers` | list\<str\> | `["dynas"]` | List of machines that should provide this route. |
| `path` | string | `"/"` | The path prefix for this route. |
| `extraConfig` | string | `""` | Extra Nginx configuration for this virtual host. |

## Features

- **Automatic TLS**: Uses Let's Encrypt (via the `acme` module) for all defined virtual hosts.
- **Path-based Routing**: Supports multiple locations for the same subdomain by grouping instances by host.
- **Tunnelling**: Support for remote providers (e.g. `ovh-pl`) to proxy traffic back to containers.
