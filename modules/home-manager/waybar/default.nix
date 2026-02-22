{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.extra.waybar;
  jsonFormat = pkgs.formats.json { };

  waybarBarConfig =
    with lib;
    with types;
    submodule {
      freeformType = jsonFormat.type;

      options = {
        modules = mkOption {
          type = jsonFormat.type;
          visible = false;
          default = null;
          description = "Modules configuration.";
        };
      };
    };
in
{
  options.extra.waybar =
    with lib;
    with types;
    {
      enable = mkEnableOption "waybar";
      settings = mkOption {
        default = { };
        type = types.attrsOf (either (listOf waybarBarConfig) (attrsOf waybarBarConfig));
      };
      configs = mkOption {
        default = { };
        type = types.attrsOf (
          types.submodule (
            { ... }:
            {
              options.nix = mkOption {
                type = types.any;
                default = { };
              };
              options.path = mkOption { type = types.pathInStore; };
              options.run = mkOption { type = types.str; };
            }
          )
        );
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
    ];
    # from https://github.com/HeinzDev/Hyprland-dotfiles
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
      style = builtins.readFile ./style.css;
    };

    extra.waybar.configs =
      with lib;
      let
        # Removes nulls because Waybar ignores them.
        # This is not recursive.
        removeTopLevelNulls = filterAttrs (_: v: v != null);

        # Makes the actual valid configuration Waybar accepts
        # (strips our custom settings before converting to JSON)
        makeConfiguration =
          configuration:
          let
            # The "modules" option is not valid in the JSON
            # as its descendants have to live at the top-level
            settingsWithoutModules = removeAttrs configuration [ "modules" ];
            settingsModules = optionalAttrs (configuration.modules != null) configuration.modules;
          in
          removeTopLevelNulls (settingsWithoutModules // settingsModules);

      in
      mapAttrs (
        n: v:
        let
          settings = if isAttrs v then attrValues v else v;
        in
        rec {
          path = jsonFormat.generate "waybar-config-${n}.json" (map makeConfiguration settings);

          run = "${config.programs.waybar.package}/bin/waybar -c '${path}'";
        }

      ) cfg.settings;
  };
}
