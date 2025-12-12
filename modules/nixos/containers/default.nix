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

  journalPort = 19532;

  mkInterfaceName =
    { name, ... }:
    let
      net = "ve-${name}";
    in
    if (builtins.stringLength net) < 16 then
      net
    else
      throw "${net} is too long for a network name, please change the name of container ${names}";

  c_config =
    {
      name,
      hostAddress,
      ...
    }:
    { lib, ... }:
    let
      c_config = config.extra.containers.${name};
      overlays = config.nixpkgs.overlays;
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
            overlays
            hostAddress
            journalPort
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
        let
          hostAddress = if value.privateNetwork then "192.168.${toString (2 + idx)}.2" else "127.0.0.1";
        in
        (
          {
            config = c_config { inherit name hostAddress; };
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
            if value.gpu then
              {
                bindMounts = {
                  "/dev/dri/renderD128" = {
                    hostPath = "/dev/dri/renderD128";
                    isReadOnly = false;
                  };
                };
                allowedDevices = [
                  {
                    node = "/dev/dri/renderD128";
                    modifier = "rw";
                  }
                ];
              }
            else
              { }
          )
          // (
            if value.privateNetwork then
              {
                privateNetwork = true;
                inherit hostAddress;
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

    nat.internalInterfaces = map mkInterfaceName (
      filter ({ value, ... }: value.privateNetwork) containers
    );
    firewall.interfaces = listToAttrs (
      map (
        attrs@{ ... }:
        {
          name = mkInterfaceName attrs;
          value = {
            allowedTCPPorts = [ journalPort ];
          };
        }
      ) (filter ({ value, ... }: value.privateNetwork) containers)
    );
  };
  services.journald.remote = {
    listen = "http";
    enable = true;
    port = journalPort;
  };
}
