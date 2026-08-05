{ inputs', pkgs, ... }:
inputs'.mango.packages.mango.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (pkgs.fetchpatch {
      url = "https://github.com/mangowm/mango/pull/1121.patch";
      hash = "sha256-Cv81tvhM5jifQF13Fk6/UFL+9ThuV2ls2xkPtFGV02g=";
    })
  ];
})
