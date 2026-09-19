{ lib, ... }:
with lib;
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
        extraIgnorePatterns = mkOption {
          default = [ ];
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
{
  options.extra.syncthing = {
    enable = mkEnableOption "syncthing" // {
      default = true;
    };
    folders = mkOption {
      type = types.attrsOf (types.submodule folderopt);
      # default = { };
    };
    defaultIgnorePatterns = mkOption {
      type = types.listOf types.str;
      default = [
        "(?d)**/.DS_Store"
        "(?d)**/._*"
      ];
    };
    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
    };
    extraUsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of users to add to the `syncthing` group";
    };
  };
}
