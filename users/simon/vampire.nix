{ custom, ... }:
{
  imports = [ ];
  home = {
    packages = (with custom; [ vampire-master ]);
  };
}
