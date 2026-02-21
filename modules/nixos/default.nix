{
  flake-parts-lib,
  self,
  inputs,
  config,
  lib,
  ...
}:
let
  emodules = with self.nixosModules; [
    tailscale
    sops
    inputs.sops-nix.nixosModules.sops
  ];

  containers = flake-parts-lib.importApply ./containers emodules;

  base =
    { lib, ... }:
    {
      options = with lib; {
        params = {
          locations = {
            containers = mkOption {
              type = types.path;
              default = "/containers";
              description = "where to put all the containers by default";
            };
          };
        };
        vars = mkOption {
          type = types.attrs;
          default = { };
        };
      };
    };

  # containers = ./containers;

  modules = {
    # default = ./default.nix;

    inherit containers base;

    tailscale = ./tailscale;
    sops = ./sops;
    acme = ./acme;
    authelia = ./authelia;
    authentik = ./authentik;
    binary-cache = ./binary-cache;
    bitwarden = ./bitwarden;
    cachefilesd = ./cachefilesd;
    calibre-web = ./calibre-web;
    controllers = ./controllers;
    docker-traefik = ./docker-traefik;
    fileflows = ./fileflows;
    github-runner = ./github-runner;
    gui = ./gui;
    headscale = ./headscale;
    immich = ./immich;
    kavita = ./kavita;
    llm = ./llm;
    mail = ./mail;
    mail-server = ./mail-server;
    monitoring = ./monitoring;
    mount-containers = ./mount-containers;
    n8n = ./n8n;
    nix-ld = ./nix-ld;
    ntfy = ./ntfy;
    paperless = ./paperless;
    photoprism = ./photoprism;
    printing = ./printing;
    refind = ./refind;
    smartd = ./smartd;
    splashscreen = ./splashscreen;
    syncthing-module = ./syncthing-module;
    tailscale-exit-container = ./tailscale-exit-container;
    torrent = ./torrent;
    traefik = ./traefik;
    v4l2loopback = ./v4l2loopback;
    virtualisation = ./virtualisation;
    wachtower = ./wachtower;
    zigbee2mqtt = ./zigbee2mqtt;
    vaultwarden = ./vaultwarden;
    usersNgroups = ./usersNgroups.nix;
  };

in
{
  options.modules.nixos =
    with lib;
    mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of nixos modules to put in the `default` module";
    };

  config = {
    modules.nixos = builtins.attrNames modules;
    flake.nixosModules = modules // {
      default = (
        { ... }:
        {
          imports = map (n: self.nixosModules.${n}) config.modules.nixos;
        }
      );
    };
  };
}
