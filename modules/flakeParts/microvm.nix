{ config, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps.sandbox = {
        type = "app";
        program = "${self.nixosConfigurations.sandbox.config.microvm.runner.qemu}/bin/microvm-run";
      };
    };
}
