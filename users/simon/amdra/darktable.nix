{
  darktable,
  pkgs,
  computer,
  ...
}:
let
  onnx = pkgs.onnxruntime.override { rocmSupport = true; };
in
(darktable.override (
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
