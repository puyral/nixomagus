{  ... }:
{
  perSystem =
    { self', ... }:
    {
      apps.sandbox = {
        type = "app";
        program = "${self'.packages.sandbox}/bin/sandbox";
      };
    };
}
