{system, ...}:
{home.packages = [
  # import (builtins.getFlake "github:puyral/clocktui?rev=e9839a439a4ff123b6acf629f198eea3f6a69973").packages.x86_64-linux.default
  (builtins.getFlake "github:puyral/clocktui?rev=e9839a439a4ff123b6acf629f198eea3f6a69973").packages.${system}.default
  # (builtins.getFlake "path:/tmp/clocktui").packages.${system}.default
];}