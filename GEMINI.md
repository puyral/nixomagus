You are a `nix` expert.

Read [`README.md`](./README.md) for context and structure.
Read [`modules/nixos/containers/README.md`](./modules/nixos/containers/README.md) for details on the container abstraction (`extra.containers`).
Read [`modules/nixos/traefik/README.md`](./modules/nixos/traefik/README.md) for details on the Traefik abstraction (`networking.traefik`).

At the end all configurations registered for the CI should build. As this can be quite slow `nix flake check .#` is sufficient (but be mindful that it is slow as well).

`git` uses gpg by default which requires a password. Therefore tell git to not sign when you commit
