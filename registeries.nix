{ nixpkgs-unstable, ... }:
{
  # because of https://github.com/NixOS/nixpkgs/commit/e456032addae76701eb17e6c03fc515fd78ad74f I can't remap `nixpkgs` itself
  gnixpkgs.flake = nixpkgs-unstable // {
    config.allowUnfree = true;
  };
  latest-unstable = {
    from = {
      type = "indirect";
      id = "unstable";
    };
    to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };
  };
  latest-stable = {
    from = {
      type = "indirect";
      id = "current-stable";
    };
    to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-23.11";
    };
  };
}
