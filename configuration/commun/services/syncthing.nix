{
  config,
  lib,
  pkgs,
  computer_name,
  rootDir,
  ...
}:

{
  services.syncthing = {
    enable = true;
    user = "simon";
    dataDir = "/tmp"; # Default folder for new synced folders
    configDir = "/config/syncthing"; # Folder for Syncthing's settings and keys

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    settings = {
      devices = builtins.removeAttrs (import (rootDir + /secrets/syncthing-devices.nix)) [
        computer_name
      ];
    };
  };
}
