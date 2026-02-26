{ ... }:
let
  users = {
    simon.fullName = "Simon Jeanteur";
  };
  system = "x86_64-linux";

in
{
  computers = {
    nixomagus = {
      inherit users system;
      # is_docked = false;
      cpuArchitecture = "skylake";
      stateVersion = "23.11";
      headless = false;
    };
    dynas = {
      inherit users system;
      stateVersion = "24.05";
      headless = true;
    };
    ovh-pl = {
      inherit users system;
      stateVersion = "23.05";
      headless = true;
      ovh = true;
    };
    vampire = {
      inherit users system;
      headless = true;
      nixos.enable = false;
      stateVersion = "23.11";
    };
    i7 = {
      inherit users system;
      stateVersion = "24.05";
      headless = false;
    };
    mydos = {
      inherit users system;
      stateVersion = "24.05";
      headless = false;
    };
    amdra = {
      inherit users system;
      stateVersion = "24.05";
      headless = false;
    };
  };

}
