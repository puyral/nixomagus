
{ config, lib, pkgs, ... }:

with lib;
{

  options.extra.fileflows = {
    enable = mkEnableOption "FileFlows Media Processing Server";

    image = mkOption {
      type = types.str;
      default = "revenz/fileflows:stable";
      description = "The OCI image to use for FileFlows.";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Directory to store FileFlows configuration and database.";
      default = "${config.params.locations.containers}/fileflows";
    };

    tempDir = mkOption {
      type = types.path;
      default = "/tmp/fileflows";
      description = "Directory for temporary transcoding files.";
    };

    mediaDirs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of media directories to mount into the container.
        They will be mounted at the same path as on the host to avoid confusion.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open port 5000 in the firewall.";
    };

    networking = {
      reverproxied = mkEnableOption "reverse proxy";
      name = mkOption {
        type = types.str;
        default = "fileflows";
        description = "name for the reverse proxy";
      };
    };

    hardware = {
      intelArc = mkEnableOption "Intel Arc (QSV) hardware acceleration support";
    };
    
    port = mkOption {
      type = types.port;
      default = 5000;
      description = "port for the container";
    };
  };
}