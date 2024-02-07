{ config, pkgs, home, ... }: {
  imports = [ ];
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      battery = { disabled = true; };
      character = {
        error_symbol = "[\\$](bold red)";
        success_symbol = "[\\$](bold green)";
      };
      cmd_duration = { show_milliseconds = true; };
      directory = {
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };
      format = "$time" + "$username" + "$hostname" + "$shlvl" + "$kubernetes"
        + "$directory" + "$git_branch" + "$git_commit" + "$git_state"
        + "$git_status" + "$hg_branch" + "$docker_context" + "$package"
        + "$cmake" + "$dart" + "$dotnet" + "$elixir" + "$elm" + "$erlang"
        + "$golang" + "$helm" + "$java" + "$julia" + "$kotlin" + "$nim"
        + "$nodejs" + "$ocaml" + "$perl" + "$php" + "$purescript" + "$python"
        + "$ruby" + "$rust" + "$swift" + "$terraform" + "$vagrant" + "$zig"
        + "$nix_shell" + "$conda" + "$memory_usage" + "$aws" + "$gcloud"
        + "$openstack" + "$env_var" + "$crystal" + "$custom" + "$cmd_duration"
        + "$line_break" + "$lua" + "$jobs" + "$battery" + "$sudo" + "$status"
        + "$character";
      git_status = { disabled = true; };
      hostname = { format = "in [$ssh_symbol$hostname]($style) "; };
      python = {
        pyenv_version_name = true;
        symbol = "🐍 ";
      };
      status = { disabled = false; };
      sudo = {
        disabled = false;
        format = "[$symbol]($style)";
        symbol = "🔑 ";
      };
      time = {
        disabled = false;
        format = "[$time]($style) ";
      };
      username = {
        disabled = false;
        format = "as [$user]($style) ";
        show_always = true;
      };
    };
  };
}
