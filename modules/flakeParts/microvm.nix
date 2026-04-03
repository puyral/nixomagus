{ config, ... }:
{
  perSystem =
    { self', ... }:
    {
      # `self'` works better here because we are using flake parts
      apps.sandbox = {
        type = "app";
        program = "${self'.packages.sandbox}/bin/sandbox"; # think before you change
      };
      apps.csandbox = {
        type = "app";
        program = "${self'.packages.csandbox}/bin/csandbox"; # think before you change
      };
    };
}
