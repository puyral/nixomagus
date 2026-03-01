{
  writeShellApplication,
  ntfy-sh,
  procps,
  coreutils,
  jq,
  libnotify,
  topic ? "cmd",
  ...
}:
{
  ntfy-done = writeShellApplication {
    name = "ntfy-done";
    runtimeInputs = [
      coreutils
      ntfy-sh
      procps
    ];
    runtimeEnv = {
      "TOPIC" = topic;
    };
    text = builtins.readFile ./ntfy-done.sh;
  };

  ntfy-forward = writeShellApplication {
    name = "ntfy-forward";
    runtimeInputs = [
      coreutils
      ntfy-sh
      jq
      libnotify
    ];
    runtimeEnv = {
      "TOPIC" = topic;
    };
    text = builtins.readFile ./ntfy-desktop.sh;
  };

}
