{ lib, config, ... }:
with lib;

{
  options.extra.extraGroups =
    let
      options =
        { ... }:
        {
          options = {
            members = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            gid = mkOption { type = types.int; };
          };
        };
    in

    mkOption {
      default = { };
      type = types.attrsOf (types.submodule options);
    };

  config.users.groups = lib.mapAttrs (
    n: v:
    {
      members = [
        "simon"
        "root"
      ]
      ++ v.members;
    }
    // (if v.gid != null then { gid = v.gid; } else { })
  ) config.extra.extraGroups;
}
