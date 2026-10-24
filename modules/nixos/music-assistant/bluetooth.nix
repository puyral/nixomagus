{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.music-assistant;
  btCfg = cfg.snapcast.bluetoothSink;
  enabled = cfg.enable && cfg.snapcast.enableBuiltinServer && btCfg.enable;

  fifoDir = "/run/snapcast-bt";
  fifoPath = "${fifoDir}/fifo";

  alsaConf = pkgs.writeText "asound-snapcast-bt.conf" ''
    pcm.null {
      type null
    }
    pcm.snapfifo_raw {
      type file
      slave.pcm "null"
      file "|${pkgs.coreutils}/bin/cat > ${fifoPath}"
      format "raw"
    }
    pcm.snapcast {
      type plug
      slave {
        pcm "snapfifo_raw"
        rate 48000
        format s16_le
        channels 2
      }
    }
  '';

  btAutoAgent = pkgs.writers.writePython3 "bt-auto-agent" {
    libraries = with pkgs.python3Packages; [
      dbus-python
      pygobject3
    ];
    flakeIgnore = [
      "E501"
    ];
  } (builtins.readFile ./bt-auto-agent.py);
in
{
  config = lib.mkIf enabled {
    boot.kernelModules = [ "btusb" ];
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Name = btCfg.name;
          # Major Service: Audio (0x200000), Major Device: Audio/Video (0x000400), Minor: Loudspeaker (0x000014)
          Class = "0x200414";
          DiscoverableTimeout = 0;
          PairableTimeout = 0;
          JustWorksRepairing = "always";
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    services.dbus.packages = [ pkgs.bluez-alsa ];

    users.users.bluealsa = {
      isSystemUser = true;
      group = "audio";
    };

    systemd.tmpfiles.rules = [
      "d ${fifoDir} 0775 bluealsa audio -"
    ];

    systemd.services.bluealsa = {
      description = "BlueALSA Bluetooth Audio daemon (A2DP Sink)";
      after = [ "bluetooth.service" ];
      requires = [ "bluetooth.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.bluealsa";
        User = "bluealsa";
        Group = "audio";
        AmbientCapabilities = [ "CAP_NET_RAW" ];
        ExecStart = "${pkgs.bluez-alsa}/bin/bluealsa -S -p a2dp-sink --a2dp-volume";
        Restart = "on-failure";
        RestartSec = 2;
        StateDirectory = "bluealsa";
      };
    };

    systemd.services.bt-sink-agent = {
      description = "Headless Bluetooth A2DP Sink Auto-Pairing Agent";
      after = [
        "bluetooth.service"
        "bluealsa.service"
      ];
      requires = [ "bluetooth.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${btAutoAgent}";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    systemd.services.bluealsa-aplay = {
      description = "BlueALSA player routing Bluetooth audio to Snapcast FIFO";
      after = [ "bluealsa.service" ];
      requires = [ "bluealsa.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        ALSA_CONFIG_PATH = "${alsaConf}";
        ALSA_PLUGIN_DIR = "${pkgs.alsa-plugins}/lib/alsa-lib:${pkgs.bluez-alsa}/lib/alsa-lib";
      };
      script = ''
        rm -f ${fifoPath}.*
        if [ ! -p ${fifoPath} ]; then
          rm -f ${fifoPath}
          ${pkgs.coreutils}/bin/mkfifo -m 0666 ${fifoPath}
        fi
        # Hold the FIFO open read-write so Snapserver never sees EOF when idle
        exec 3<>${fifoPath}
        exec ${pkgs.bluez-alsa}/bin/bluealsa-aplay -S --pcm=snapcast --profile-a2dp --volume=software
      '';
      serviceConfig = {
        User = "bluealsa";
        Group = "audio";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    extra.music-assistant.snapcast = {
      extraBindMounts."${fifoDir}" = {
        hostPath = fifoDir;
        isReadOnly = false;
      };
      sources = lib.mkBefore [
        "pipe://${fifoPath}?name=default&mode=read&sampleformat=48000:16:2"
      ];
    };
  };
}
