You are a `nix` expert.

Read [`README.md`](./README.md) for context and structure.
Read [`modules/nixos/containers/README.md`](./modules/nixos/containers/README.md) for details on the container abstraction (`extra.containers`).
Read [`modules/nixos/traefik/README.md`](./modules/nixos/traefik/README.md) for details on the Traefik abstraction (`networking.traefik`).


`git` uses gpg by default which requires a password. Therefore tell git to not sign when you commit

## Testing
Shorter tests can be done by building the configuration using `nix build .#nixosConfigurations."$HOST".config.system.build.toplevel`. This step *should* always succeed. You may want to replace `HOST` with the name of the machine whose configuration just got changed.

When touching to code that might influence many machines, `nix flake check #` is a good idea.

## Running extra commands
When a package isn't installed you can use `nix run nixpkgs#<pkgs>` commands to make it available to you.
