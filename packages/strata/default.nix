{
  lib,
  cmake,
  ninja,
  makeWrapper,
  python3,
  symlinkJoin,
  rocmPackages,
  pkgs-strata,
  strata-src,
  ...
}:

let
  # One merged ROCm root (what upstream's build scripts use): the HIP compiler
  # finds the device bitcode and CMake finds the hip/hipblas/hipblaslt/rocblas
  # configs under a single --rocm-path / CMAKE_PREFIX_PATH.
  rocmRoot = symlinkJoin {
    name = "strata-rocm-root";
    paths = with rocmPackages; [
      clr
      hipblas
      hipblaslt
      rocblas
      rocm-runtime
      rocm-device-libs
    ];
  };
  # hipBLASLt solution table calibrated on an R9700 (gfx1201) for hipBLASLt
  # 1.2.2 — exactly what nixpkgs' ROCm 7.2.3 ships. It roughly doubles prompt
  # speed over plain hipBLAS on this stack (docs/AMD_HIP.md, RDNA4 section); the
  # engine re-checks the table's arch/version header at startup and falls back
  # to plain hipBLAS if it does not match.
  tuningTable = strata-src + "/tools/hip/gfx1201-hipblaslt-100202.txt";
  # CLI dependencies: the serve/bench imports plus textual (launch screens, monitor)
  pyEnv = python3.withPackages (
    ps: with ps; [
      jinja2
      numpy
      pillow
      psutil
      pyyaml
      regex
      requests
      textual
      tqdm
    ]
  );
in

rocmPackages.rocmClangStdenv.mkDerivation {
  pname = "strata";
  version = "0.1.55";

  src = strata-src;

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
    python3
  ];

  buildInputs = with rocmPackages; [
    clr
    hipblas
    hipblaslt
    rocblas
    rocm-runtime
    rocm-device-libs
  ];

  env.HIP_PLATFORM = "amd";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSTRATA_ENABLE_HIP=ON"
    "-DSTRATA_ENABLE_CUDA=OFF"
    # AMD RX 9070 XT (gfx1201); also builds for gfx1200 (RX 9070)
    "-DCMAKE_HIP_ARCHITECTURES=gfx1200;gfx1201"
    "-DCMAKE_HIP_COMPILER=${rocmPackages.rocmClangStdenv.cc}/bin/clang++"
    "-DCMAKE_HIP_FLAGS=--rocm-path=${rocmRoot}"
    "-DCMAKE_PREFIX_PATH=${rocmRoot}"
    # GGML from the pinned nixpkgs-strata snapshot's llama-cpp source (v0.6.0,
    # has the Q2_0 type Strata's MMQ path needs). nixpkgs-unstable moved to
    # llama-cpp v0.8.0, whose reworked ggml-cuda MMQ API no longer compiles.
    "-DSTRATA_GGML_DIR=${pkgs-strata.llama-cpp.src}"
    "-DSTRATA_BUILD_TESTS=OFF"
    # upstream rx9070 recipe
    "-DSTRATA_PREFILL_MMQ=ON"
    # AVX2 baseline, like every validated upstream package
    "-DSTRATA_PORTABLE=ON"
  ];

  installPhase = ''
    runHook preInstall

    # ---- engine, installed as a Strata engine component -----------------
    # (<components>/engine/<version>-linux-x86_64-hip/ is what `strata launch`
    # and `strata serve --profile` look for via STRATA_COMPONENTS_DIR).
    comp=$out/share/strata/components/engine/0.1.55-linux-x86_64-hip
    mkdir -p $comp/tuning
    cp strata strata-device $comp/
    cp ${tuningTable} $comp/tuning/
    cat > $comp/BUILD.json <<'EOF'
    {"version": "0.1.55", "archs": ["gfx1200", "gfx1201"], "hipblaslt_version": 100202, "portable": true}
    EOF

    # ---- the Terminal (CLI + server) -----------------------------------
    app=$out/share/strata/app
    mkdir -p $app/bench
    cp -r $src/strata.py $src/setup.py $src/requirements.txt $src/requirements-monitor.txt \
          $src/strata_cli $src/strata_control $src/serve $src/tools $src/data \
          $src/integrations $src/third_party $app/
    cp -r $src/bench/prompts $app/bench/prompts

    # The CLI keeps run configs and state in per-user folders; without this the
    # install dir would default next to the read-only component folder in the
    # store. An explicit STRATA_INSTALL_DIR from the user still wins.
    makeWrapper ${pyEnv}/bin/python3 $out/bin/strata \
      --add-flags $app/strata.py \
      --set STRATA_COMPONENTS_DIR $out/share/strata/components \
      --run ': ''${STRATA_INSTALL_DIR:=''${XDG_DATA_HOME:-$HOME/.local/share}/strata/install}' \
      --run 'export STRATA_INSTALL_DIR' \
      --set-default STRATA_HIPBLASLT_TUNING $comp/tuning/gfx1201-hipblaslt-100202.txt

    makeWrapper $comp/strata $out/bin/strata-engine \
      --set-default STRATA_HIPBLASLT_TUNING $comp/tuning/gfx1201-hipblaslt-100202.txt
    ln -s $comp/strata-device $out/bin/strata-device

    runHook postInstall
  '';

  # The engine-component.json hashes every packaged file, so it must be
  # generated after fixupPhase (strip / patchelf rewrite the binaries).
  postFixup = ''
    comp=$out/share/strata/components/engine/0.1.55-linux-x86_64-hip
    python3 - "$comp" <<'PY'
    import hashlib, json, os, sys
    folder = sys.argv[1]
    rels = ["strata", "strata-device", "BUILD.json", "tuning/gfx1201-hipblaslt-100202.txt"]
    files = []
    for rel in rels:
        with open(os.path.join(folder, rel), "rb") as fh:
            data = fh.read()
        files.append({"path": rel, "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)})
    manifest = {
        "schema_version": 2, "id": "strata-engine", "name": "strata-engine",
        "version": "0.1.55", "platform": "linux-x86_64", "backend": "hip",
        "archs": ["gfx1200", "gfx1201"], "min_driver": {}, "build_id": "nix",
        "entrypoint": "strata", "files": files, "signature": None,
    }
    with open(os.path.join(folder, "engine-component.json"), "w") as fh:
        json.dump(manifest, fh, indent=1)
        fh.write("\n")
    PY
    PYTHONPATH=$src python3 -c "
    from pathlib import Path
    from strata_control import engine_component as ec
    ec.verify(ec.read_manifest(Path('$comp')), full=True)
    print('engine-component.json verified')"
  '';

  meta = {
    description = "Strata: run LLMs locally (Terminal CLI + engine, HIP build for AMD RDNA4)";
    homepage = "https://github.com/Niko1221/Strata";
    mainProgram = "strata";
    platforms = lib.platforms.linux;
  };
}
