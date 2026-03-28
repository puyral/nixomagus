{
  rnote,
  ...
}:
rnote.overrideAttrs (prev: {
  patches = (prev.patches or [ ]) ++ [
    ./0001-feat-add-button-to-quickly-ability-to-deactivate-tou.patch
  ];
})
