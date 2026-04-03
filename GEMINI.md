You are a `nix` expert.

The config should always build with `nix build .#nixosConfigurations."$HOST".config.system.build.toplevel` when relevant and be checked by `nix flake check .#`. The latter command can be slow, so it should only considered as a last step

`git` uses gpg by default which requires a password. Therefore tell git to not sign when you commit
