{ lib, ... }: {
  options = with lib; {
    params = {
      locations = {
        containers = mkOption {
          type = types.path;
          default = "/containers";
          description = "where to put all the containers by default";
        };
      };
    };
    vars = mkOption {
      type = types.attrs;
      default = { };
    };
  };
}
