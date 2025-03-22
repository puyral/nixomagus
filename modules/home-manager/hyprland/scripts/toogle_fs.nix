{
  writeShellApplication,
  hyprland,
  ...
}:

writeShellApplication {
  name = "toogle_fs";

  runtimeInputs = [
    hyprland
  ];

  text = builtins.readFile ./toogle_fs.sh;
}
