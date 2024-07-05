# https://chatgpt.com/c/a206d21e-450c-437e-b13f-e5463925f13f
# overlay.nix
mconfig: {
  gottagofast =
    self: super:

    let
      # Retrieve the current CPU flags using `nixpkgs.localSystem` settings
      cpuFlags = [
        "-march=${mconfig.cpu}" # Example: you can customize this based on your actual CPU flags
        "-O2"
        # Add more flags as necessary
      ];
      customStdenv = super.pkgs.fastStdenv // {
        inherit (super.pkgs.fastStdenv);
        # Override the mkDerivation function to add CPU flags
        mkDerivation =
          with builtins;
          args:
          super.pkgs.fastStdenv.mkDerivation (
            args
            // {
              buildInputs = (args.buildInputs or [ ]) ++ [ super.pkgs.gcc ];
              CFLAGS = concatStringsSep " " (cpuFlags ++ [ (args.CFLAGS or "") ]);
              CXXFLAGS = concatStringsSep " " (cpuFlags ++ [ (args.CXXFLAGS or "") ]);
            }
          );
      };
    in
    {
      # Override the default stdenv with our customStdenv
      stdenv = customStdenv;
    };
}
