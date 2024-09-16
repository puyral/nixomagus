rec {
  recMerge =
    with builtins;
    lhs: rhs:
    if !((isAttrs lhs) || (isAttrs rhs)) then
      rhs
    else
      let
        lnames = builtins.attrNames lhs;
        rnames = builtins.attrNames rhs;
        attl = builtins.map (n: {
          name = n;
          value = if builtins.hasAttr n then recMerge lhs.${n} rhs.${n} else lhs.${n};
        }) lnames;
        attr = builtins.map (name: {
          inherit name;
          value = rhs.${name};
        }) (builtins.filter (n: !(builtins.hasAttr n lhs)) rnames);
      in
      builtins.listToAttrs (attl ++ attr);
}
