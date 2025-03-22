rec {
  computers = {
    nixomagus = {
      system = "x86_64-linux";
      is_docked = false;
      cpu = "skylake";
      users = [ users.simon ];
      nixos = "23.11";
      headless = false;
    };
    dynas = {
      system = "x86_64-linux";
      # cpu = "skylake";
      users = [ users.simon ];
      nixos = "24.05";
      headless = true;
    };
    ovh-pl = {
      system = "x86_64-linux";
      # cpu = "skylake";
      users = [ users.simon ];
      nixos = "23.05";
      headless = true;
      ovh = true;
    };
    vampire = {
      system = "x86_64-linux";
      users = [ users.simon ];
      headless = true;
    };
    i7 = {
      system = "x86_64-linux";
      users = [ users.simon ];
      nixos = "24.05";
      headless = false;
    };
    mydos = {
      system = "x86_64-linux";
      users = [ users.simon ];
      nixos = "24.05";
      headless = false;
    };
    amdra = {
      is_docked = true;
      system = "x86_64-linux";
      users = [ users.simon ];
      nixos = "24.05";
      headless = false;
    };
  };

  users = {
    simon = {
      name = "simon";
      description = "Simon Jeanteur";
    };
  };
}
