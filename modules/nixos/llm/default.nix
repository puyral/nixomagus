{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.extra.llm;
in
{

  options.extra.llm = {
    enable = lib.mkEnableOption "llm";
  };

  config = lib.mkIf cfg.enable {
    # Enable OLLAMA
    services.ollama = {
      enable = true;
    };

    services.open-webui = {
      enable = true;
      port = 8081;
      openFirewall = true;
    };
  };

}
