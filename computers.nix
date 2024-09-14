rec {
  computers = {
    nixomagus = {
      system = "x86_64-linux";
      is_docked = true;
      cpu = "skylake";
      users = [ users.simon ];
      nixos = true;
      headless = false;
    };
    dynas = {
      system = "x86_64-linux";
      # cpu = "skylake";
      users = [ users.simon ];
      nixos = true;
      headless = true;
    };
    vampire = {
      system = "x86_64-linux";
      users = [ users.simon ];
      nixos = false;
      headless = true;
    };
  };

  users = {
    simon = {
      name = "simon";
    };
  };
}
