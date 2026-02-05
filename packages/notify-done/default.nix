{
  writeShellApplication,
  ntfy-sh,
  procps,
  coreutils,
  topic ? "cmd",
  ...
}:
writeShellApplication {
  name = "ntfy-done";
  runtimeInputs = [
    coreutils
    ntfy-sh
    procps
  ];
  runtimeEnv = {
    "TOPIC" = topic;
  };
  text = builtins.readFile ./script.sh;
}
