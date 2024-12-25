{
  mlib,
  config,
  mconfig,
  lib,
  rootDir,
  nixpkgs-unstable,
  pkgs-unstable,
  my-nixpkgs,
  ...
}:
with lib;
with builtins;
let

  c_config =
    name:
    { lib, ... }:
    {
      imports = [ (rootDir + "/registeries.nix") ];
      system.stateVersion = mconfig.nixos;
      networking = {
        firewall.enable = false;
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };
      services.resolved.enable = true;

      services.openssh = {
        enable = true;
      };

      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      #services.zerotierone =
      #  if config.extra.containers.${name}.zerotierone then
      #    let
      #      networks = import (rootDir + /secrets/zerotier-networks.nix);
      #    in
      #    {
      #      enable = true;
      #      joinNetworks = [ networks.vidya.id ];
      #    }
      #  else
      #    { };
    };
  names = builtins.attrNames config.extra.containers;
  enames = mlib.enumerate names;
  content = map (
    { idx, value }:
    {
      inherit idx;
      name = value;
      value = config.extra.containers.${value};
    }
  ) enames;
in

{
  options.extra.containers =
    let
      options =
        { name, ... }:
        {
          options = {
            vpn = mkOption {
              type = types.bool;
              default = false;
              description = "enable vpn access";
            };
            traefik = (import ../traefik/options.nix) lib // {
              name = mkOption {
                type = types.str;
                default = name;
                description = "the subdomain name";
              };
              enable = mkEnableOption "traefik redirection";
            };
            privateNetwork = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
    in
    mkOption {
      type = types.attrsOf (types.submodule options);
      default = { };
    };

  config = {
    containers =
      let
        f =
          attrs@{
            idx,
            value,
            name,
          }:
          (
            {
              config = c_config name;
              specialArgs = {
                inherit
                  mlib
                  nixpkgs-unstable
                  pkgs-unstable
                  my-nixpkgs
                  ;
              };
            }
            // (if value.vpn then { enableTun = true; } else { })
            // (
              if value.privateNetwork then
                {
                  privateNetwork = true;
                  hostAddress = "192.168.${toString (2 + idx)}.2";
                  localAddress = "192.168.100.${toString (2 + idx)}";
                }
              else
                { }
            )
          );

        result = listToAttrs (
          map (
            attrs@{ name, ... }:
            {
              inherit name;
              value = f attrs;
            }
          ) content
        );
      in
      result;
    networking = {
      traefik.instances = (
        let
          f = { value, name, ... }: (builtins.removeAttrs value.traefik [ "name" ]) // { container = name; };
        in
        listToAttrs (
          map (attrs: {
            name = if attrs.value ? traefik then attrs.value.traefik.name else attrs.name;
            value = f attrs;
          }) content
        )
      );

      nat.internalInterfaces = map (
        { name, ... }:
        let
          net = "ve-${name}";
        in
        if (builtins.stringLength net) < 16 then
          net
        else
          throw "${net} is too long for a network name, please change the name of container ${names}"
      ) (filter ({ value, ... }: value.privateNetwork) content);
    };
  };
}
