{ lib, config, ... }:
with lib;
let
  cfg = config.extra.syncthing;
  name = config.networking.hostName;
  shareFolder = folder: builtins.hasAttr name folder.devices;
  menabled = with builtins; any shareFolder (attrValues cfg.folders);
  defaultIgnorePatterns = ["(?d)**/.DS_Store" "(?d)**/._*"];
in

{
  imports = [ ./folders.nix ];
  options.extra.syncthing = {
    folders =
      let
        folderopt =
          { ... }:
          {
            options = {
              id = mkOption { type = types.str; };
              syncXattrs = mkOption {
                type = types.bool;
                default = true;
              };
              devices = mkOption {
                default = { };
                type = types.attrsOf (types.submodule deviceopts);
              };
              extraDevices = mkOption {
                default = [ ];
                type = types.listOf types.str;
              };
              extraIgnorePatterns =  mkOption {
                default = [];
                type = with types; listOf str;
              };
            };
          };
        deviceopts =
          { ... }:
          {
            options = {
              path = mkOption { type = types.path; };
              enable = mkOption {
                type = types.bool;
                default = false;
              };
            };
          };
      in
      mkOption {
        type = types.attrsOf (types.submodule folderopt);
        # default = { };
      };
  };

  config.services.syncthing = mkIf menabled {
    enable = true;
    user = "simon";
    dataDir = "/tmp"; # Default folder for new synced folders
    configDir = "/config/syncthing"; # Folder for Syncthing's settings and keys
    openDefaultPorts = true;

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    settings = {
      devices = builtins.removeAttrs (import ./secrets/devices.nix) [ name ];

      folders = builtins.mapAttrs (n: folder: {
        id = folder.id;
        syncXattrs = folder.syncXattrs;
        path = folder.devices.${name}.path;
        enabled = folder.devices.${name}.enable;
        devices = (with builtins; attrNames (removeAttrs folder.devices [ name ])) ++ folder.extraDevices;
        ignorePatterns = defaultIgnorePatterns ++ folder.extraIgnorePatterns;
      }) (filterAttrs (n: folder: shareFolder folder) cfg.folders);
    };
  };
}
