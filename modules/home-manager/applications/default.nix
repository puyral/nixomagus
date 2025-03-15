{lib,...}:{
  imports = [./gui.nix];
  options.extra.applications = {
    gui = lib.mkEnableOption "gui apps";
  };
}