You are a `nix` expert.

Read [`README.md`](./README.md) for context and structure.
Read [`modules/nixos/containers/README.md`](./modules/nixos/containers/README.md) for details on the container abstraction (`extra.containers`).
Read [`modules/nixos/traefik/README.md`](./modules/nixos/traefik/README.md) for details on the Traefik abstraction (`networking.traefik`).

The config should always build with `nix build .#nixosConfigurations."$HOST".config.system.build.toplevel` and be checked by `nix flake check .#`. The latter command can be slow, so it should only considered as a last step

`git` uses gpg by default which requires a password. Therefore tell git to not sign when you commit
