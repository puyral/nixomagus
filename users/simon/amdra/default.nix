{
  pkgs,
  pkgs-unstable,
  pkgs-self,
  computer,
  ...
}:
{
  imports = [ ./darktheme.nix ];
  extra = {
    applications.gui.enable = true;
    emacs = {
      enable = true;
      squirrel.enable = true;
    };
    i3 = {
      enable = false;
      xrandr = "--output HDMI-1 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-2 --off --output DP-3 --off";
    };
    logseq.enable = true;
    wallpaper.enable = true;
    sway.enable = true;
    mangowc = {
      enable = true;
      monitors = [
        {
          name = "DP-3";
          width = 3840;
          height = 2160;
          x = 1280;
          y = 0;
          refresh = 60;
        }
        {
          name = "HDMI-A-1";
          width = 1280;
          height = 1024;
          x = 0;
          y = 0;
          refresh = 60;
        }
      ];
    };
    hyprland = {
      enable = true;
      monitors = [
        [
          "DP-1"
          "3840x2160"
          "1280x0"
          "1"
          "bitdepth"
          "10"
        ]
        [
          "HDMI-A-1"
          "1280x1024"
          "0x0"
          "1"
        ]
      ];
    };
    darktable =
      let
        onnx = pkgs.onnxruntime.override { rocmSupport = true; };
        darktable =
          (pkgs-unstable.darktable.override (
            oldArgs:
            (builtins.intersectAttrs oldArgs pkgs)
            // {
              withAi = true;
              onnxruntime = onnx;
            }
          )).overrideAttrs
            (old: {
              NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -march=${computer.cpuArchitecture}";
              # Disable OpenCV during CMake configuration to prevent the Protobuf collision
              # because https://github.com/ROCm/AMDMIGraphX/issues/5089
              cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUSE_GMIC=OFF" ];

              # Target the binaries individually instead of using global makeWrapperArgs
              postFixup = (old.postFixup or "") + ''
                # 1. Wrap the GUI with the standard --conf flag
                wrapProgram $out/bin/darktable \
                  --add-flags "--conf plugins/ai/ort_library_path=${onnx}/lib/libonnxruntime.so"
              '';

              # Alternatively, if the CMake flag doesn't perfectly isolate it,
              # you can forcefully drop OpenCV from the build inputs entirely:
              # buildInputs = builtins.filter (p: (builtins.parseDrvName p.name).name != "opencv") old.buildInputs;
            })

        ;

      in
      {
        library = "/home/simon/.config/synced-darktable-database/library.db";
        export = {
          jpgsDir = "/Volumes/Zeno/media/photos/full-export/jpegs";
        };
        package = darktable;
      };
    llm-clients = {
      enable = true;
      lean.enable = true;
      mcp-nix.enable = true;
    };
  };

  home = {

    packages =
      (with pkgs; [
        nvtopPackages.amd
        kitty
        vampire
        hugin
        rocmPackages.migraphx
      ])
      ++ (with pkgs-unstable; [ fastfetch ]);
  };
}
