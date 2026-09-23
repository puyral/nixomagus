{ ... }: {
  imports = [ ./options.nix ];
  config.vars.gatewayMachine = "ovh-fr";
}
