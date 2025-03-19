{ rootDir, ... }:
{
  imports = [ (rootDir + "/registeries.nix") ];
  nixpkgs.config = {
    allowUnfree = _:true;
  };
}
