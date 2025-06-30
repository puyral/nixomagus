This is the nixos configuration for all the computers in [computers.nix](./computers.nix).

It merges nixos configuration and home-manager configurations. It supports home-manager-only configuration (notably for `vampire`). [`lib/default.nix`](./lib/default.nix) contains the routing logic to merge everything together.

# Structure
## [Modules](./modules)
The configuration is split quite a lot into modules. The ones for nixos are put in [modules/nixos](modules/nixos) and thoses for homemanager are in [modules/home-manager](modules/home-mananger).

By convention, all extra modules are namespaced into `extra`. `config.vars` is reserved for cross module variables.

## [Nixos](./configuration)
The configurations for nixos are in [`configuration`](./configuration). There is one folder per computer and a [`commun`](./configuration/commun) folder. Both are loaded. All modules are loaded.

## [Homemanager](./users)
Simlarily to nixos, there is one folder per user and computer and a commun folder for each. All modules are loaded.

## [devshells](./devShells)
There are some devshells stored into [`devShells`](./devShells). Theses can be usefull to reuse shells (e.g., `lean`) or avoid polutting a repo while nixifying it.

## [packages](./packages)
contains packages usefull for the configuration but that only make sense there. Otherwise my custom packages are put in [`custom-nix`](https://github.com/puyral/custom-nix)

# Secrets
Secrets are hidden using [`git-crypt`](https://github.com/AGWA/git-crypt) and [`sops-nix`](https://github.com/Mic92/sops-nix) depending on when I need access to the secret and if I only hidding them form github.
