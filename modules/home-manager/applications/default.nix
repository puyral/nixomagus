{lib,...}:{
  imports = [./gui.nix];
  options.extra.applications = {
    gui = {enable = lib.mkEnableOption "gui apps";
    pinentry-qt = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    };
  };
}