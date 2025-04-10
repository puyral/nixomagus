{
  rustPlatform,
  mkShell,
  custom,
  cargo-expand,
  rust-analyzer,
  cargo,
  cargo-nextest,
  libadwaita,
  wrapGAppsHook,
  pkgs,
  ...
}:
mkShell {
  name = "rnote";
  buildInputs =
    custom.rnote.buildInputs
    ++ custom.rnote.nativeBuildInputs
    ++ [
      cargo
      cargo-expand
      rust-analyzer
      cargo-nextest
      wrapGAppsHook

      libadwaita
    ];
  shellHook = ''
    export GSETTINGS_SCHEMA_DIR=${pkgs.glib.getSchemaPath pkgs.gtk4}
  '';
}
