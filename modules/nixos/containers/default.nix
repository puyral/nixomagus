{
  mlib,
  config,
  mconfig,
  lib,
  ...
}:
with lib builtins;
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
  names = attrsNames config.containers;
  enames = mlib.enumerate names;
  content = map (
    { idx, value }:
    {
      inherit idx;
      name = value;
      value = config.containers.${value};
    }
  ) enames;
in

{
  options.containers =
    let
      options =
        { name, ... }:
        {
          options = {
            zerotierone = mkEnableOption "zerotier vpn";
            traefik = (import ../traefik/options.nix) lib;
          };
        };
    in

    mkOption { type = types.attrsOf (types.submodule options); };

  config.containers =
    let
      f =
        {
          idx,
          value,
          name,
        }:
        {
          hostAddress = "192.168.${toString (2 + idx)}.2";
          localAddress = "192.168.100.${toString (2 + idx)}";
          config = c_config name;
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
  config.networking.traefik.instance =
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

}
