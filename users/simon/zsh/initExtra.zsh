s() {
  local pkgs=()
  for arg in "$@"; do
    pkgs+="nixpkgs#$arg"
  done
  nix shell ${pkgs[*]}
}

r() {
  local pkg=$1
  shift 1
  nix run nixpkgs#$pkg -- $@
}