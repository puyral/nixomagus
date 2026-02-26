{ lib, ... }:
with lib;
let
  mkPreEnabledOption =
    name:
    mkOption {
      type = types.bool;
      description = "Enable ${name}";
      default = true;
    };
  ipOption =
    d:
    mkOption {
      type = types.nullOr types.str;
      description = "ip in ${d}";
      default = null;
    };
  options =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        system = mkOption {
          type = types.str;
          default = "x86_64-linux";
        };
        stateVersion = mkOption {
          type = types.str;
        };
        headless = mkOption {
          type = types.bool;
        };
        ovh = mkEnableOption "ovh vps specific";

        users = mkOption {
          type = with types; attrsOf (submodule usersOptions);
        };

        nixos.enable = mkPreEnabledOption "nixos";
        homeManager.enable = mkPreEnabledOption "home manager";

        cpuArchitecture = mkOption {
          type = types.nullOr types.str;
          example = "skylake";
          default = null;
        };

        networking = {
          localIp = ipOption "the local network";
          tailscaleIp = ipOption "the tailnet";
          sshPubKey = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };

      };
    };

  usersOptions =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        fullName = mkOption {
          type = types.str;
          default = name;
        };
      };
    };

in
{
  options.computers = mkOption {
    type = with types; attrsOf (submodule options);
    default = { };
  };
}
