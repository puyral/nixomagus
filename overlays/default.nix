args@{ computer, ... }:
let
  hostPath = ./. + "/${computer.name}";
in
if builtins.pathExists hostPath then import hostPath args else { }
