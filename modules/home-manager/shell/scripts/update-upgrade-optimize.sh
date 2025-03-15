#!/usr/bin/env -S nix shell nixpkgs#bash--command bash

sudo echo "sudo aquired"
nix flake update /config#
sudo nixos-rebuild switch --flake '/config'
nix store optimise