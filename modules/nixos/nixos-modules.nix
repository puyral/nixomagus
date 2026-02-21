{
  nixosModules = rec {
    default = ./default.nix;

    acme = ./acme;
    authelia = ./authelia;
    authentik = ./authentik;
    binary-cache = ./binary-cache;
    bitwarden = ./bitwarden;
    cachefilesd = ./cachefilesd;
    calibre-web = ./calibre-web;
    containers = ./containers;
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
    tailscale = ./tailscale;
    tailscale-exit-container = ./tailscale-exit-container;
    torrent = ./torrent;
    traefik = ./traefik;
    v4l2loopback = ./v4l2loopback;
    virtualisation = ./virtualisation;
    wachtower = ./wachtower;
    zigbee2mqtt = ./zigbee2mqtt;
    vaultwarden = ./vaultwarden;
  };
}
