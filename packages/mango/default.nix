{ inputs', pkgs, ... }:
inputs'.mango.packages.mango.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (pkgs.fetchpatch {
      url = "https://github.com/mangowm/mango/pull/1121.patch";
      sha256 = "02bgb1v7qlizaj5xqy3f3cz6cp4nq1l8mbrqax26mcvjbpi7kc1l";
    })
  ];
})
