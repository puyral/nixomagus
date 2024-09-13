{ custom, ... }:
{
  imports = [ ];
  home = {
    packages = (with custom; [ vampire-master ]);
  };
  services.gpg-agent.enable = true;
}
