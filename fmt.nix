{inputs, ... }:
{
  imports = [
  inputs.treefmt-nix.flakeModule
];


perSystem.treefmt = {
  # Used to find the project root
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    ".git-crypt/*"
    ".gitattributes"
  ];
  programs.nixfmt.enable = true;
};

}