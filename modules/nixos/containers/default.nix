{
  mlib,
  config,
  mconfig,
  lib,
  ...
}:
with lib;
with builtins;
let

  cfg = name: config.containers.${name};
  c_config =
    name:
    { lib, ... }:
    {
      system.stateVersion = mconfig.nixos;
      networking = {
        firewall.enable = false;
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };
      services.resolved.enable = true;

      # users.users."root".openssh.authorizedKeys.keys =
      #   config.users.users."root".openssh.authorizedKeys.keys;
      services.openssh = {
        enable = true;
        # openFirewall = true;
      };

      nixpkgs.config.allowUnfree = true;

      services.zerotierone = mkIf (cfg name).zerotierone (
        let
          networks = import (rootDir + /secrets/zerotier-networks.nix);
        in
        {
          enable = true;
          joinNetworks = [ networks.vidya.id ];
        }
      );
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
            zerotierone = mkEnableOption "zerotier vpn";
            traefik = (import ../traefik/options.nix) lib;
            privateNetwork = mkEnableOption "private network";
          };
        };
    in

    mkOption { type = types.attrsOf (types.submodule options); };

  config = {
    containers =
      let
        f =
          {
            idx,
            value,
            name,
          }:
          {
            config = c_config name;
          }
          // mkIf value.zerotierone { enableTun = true; }
          // mkIf value.privateNetwork {
            hostAddress = "192.168.${toString (2 + idx)}.2";
            localAddress = "192.168.100.${toString (2 + idx)}";
          };
      in
      listToAttrs (
        map (
          attrs@{ name, ... }:
          {
            inherit name;
            value = f attrs;
          }
        ) content
      );
    networking = {
      traefik.instance =
        let
          f =
            {
              idx,
              value,
              name,
            }:
            value.traefik // { container = name; };
        in
        listToAttrs (
          map (
            attrs@{ name, ... }:
            {
              inherit name;
              value = f attrs;
            }
          ) content
        );

      nat.internalInterfaces = map (
        { name, ... }:
        let
          net = "ve-${name}";
        in
        assertMsg (
          (stringLength net) < 16
        ) "${net} is too long for a network name, please change the name of container ${names}" net
      ) (filter ({ value, ... }: value.privateNetwork) content);
    };
  };
}
