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
      host = "0.0.0.0";
    };

    services.open-webui = {
      enable = true;
      port = 8081;
      openFirewall = true;
      host = "0.0.0.0";
      environment = {
        HOME = "/var/lib/open-webui";
      };
    };
  };

}
