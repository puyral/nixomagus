s() {
  local pkgs=()
  for arg in "$@"; do
    pkgs+="gnixpkgs#$arg"
  done
  nix shell ${pkgs[*]}
}

r() {
  local pkg=$1
  shift 1
  nix run gnixpkgs#$pkg -- $@
}

