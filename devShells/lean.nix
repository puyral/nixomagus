{pkgs, mkShell, ...}:
mkShell {
          name = "leanspi";
          buildInputs = with pkgs; [ elan nixd ];
        }
