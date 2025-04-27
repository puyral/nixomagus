eimports:
{
  mlib,
  config,
  mconfig,
  lib,
  rootDir,
  nixpkgs-unstable,
  pkgs-unstable,
  ...
}:
with lib;
with builtins;
let

  c_config =
    name:
    { lib, ... }:
    let
      c_config = config.extra.containers.${name};
    in
    {
      imports = eimports ++ [
        (rootDir + "/registeries.nix")
        ((import ./base_config.nix) {
          inherit
            name
            pkgs-unstable
            lib
            c_config
            ;
        })
      ];
      system.stateVersion = mconfig.nixos;
    };
  names = builtins.attrNames config.extra.containers;
  enames = mlib.enumerate names;
  containers = map (
    { idx, value }:
    {
      inherit idx;
      name = value;
      value = config.extra.containers.${value};
    }
  ) enames;
in

{
  imports = [ ./options.nix ];
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
              # extra arguments given to the containers
              inherit
                mlib
                nixpkgs-unstable
                pkgs-unstable
                rootDir
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
        ) containers
      );
    in
    result;
  networking = {
    traefik.instances = (
      let
        f = { traefik, name }: (builtins.removeAttrs traefik [ "name" ]) // { container = name; };
        mkperContainerList =
          { value, name, ... }:
          map (value: {
            inherit name;
            traefik = value;
          }) (value.traefik or [ ]);
        tf_configs = builtins.concatMap mkperContainerList containers;
      in
      listToAttrs (
        map (
          attrs@{ traefik, name }:
          {
            name = traefik.name or name;
            value = f attrs;
          }
        ) tf_configs
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
    ) (filter ({ value, ... }: value.privateNetwork) containers);
  };
}
