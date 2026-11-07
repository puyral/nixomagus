{ lib, config, mlib, pkgs, ... }:
with lib;
let
  cfg = config.extra.syncthing;
  name = config.networking.hostName;
  shareFolder = folder: builtins.hasAttr name folder.devices;
  menabled = with builtins; cfg.enable && (any shareFolder (attrValues cfg.folders));

  deviceFolder = ./devices/secrets;
  deviceFiles = builtins.readDir deviceFolder;

  # Filter regular files (or symlinks if needed) and read their contents
  devices =
    with builtins;
    mapAttrs (name: type: {
      id = lib.strings.trim (mlib.readEncrypted (deviceFolder + "/${name}"));
    }) (lib.filterAttrs (name: type: type == "regular") deviceFiles);
in

{
  imports = [
    ./folders.nix
    ./options.nix
  ];

  config = mkIf menabled {
    services.syncthing = {
      enable = true;
      user = "simon";
      dataDir = "/tmp"; # Default folder for new synced folders
      configDir = "/config/syncthing"; # Folder for Syncthing's settings and keys
      openDefaultPorts = true;

      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI

      guiAddress = cfg.guiAddress;

      settings = {
        inherit devices;

        folders = builtins.mapAttrs (n: folder: {
          id = folder.id;
          syncXattrs = folder.syncXattrs;
          path = folder.devices.${name}.path;
          enabled = folder.devices.${name}.enable;
          devices = (with builtins; attrNames (removeAttrs folder.devices [ name ])) ++ folder.extraDevices;
          ignorePatterns = cfg.defaultIgnorePatterns ++ folder.extraIgnorePatterns;
        }) (filterAttrs (n: folder: shareFolder folder) cfg.folders);
      };
    };
    extra.extraGroups = lib.genAttrs cfg.extraUsers (u: {
      members = [ "syncthing" ];
    });

  };
}
