rec {
  mkC = normal: bright: {
    normal = normal;
    bright = bright;
  };

  asList = colors:
    let c = colors.colors;
    in [ c.black c.red c.green c.yellow c.magenta c.cyan c.white ];

  asIndexed = colors:
    let main_colors = asList colors;
    in (map (c: c.normal) main_colors) ++ (map (c: c.birght) main_colors);

  # ----- palletes -------
  mainPallette = {
    foreground = "#ffffff";
    background = "#121314";

    colors = {
      black = mkC "#131314" "#373b41";
      red = mkC "#cc342b" "#ff655c";
      green = mkC "#198844" "#5fe392";
      yellow = mkC "#fba922" "#f5bc5f";
      blue = mkC "#3971ed" "#6896fc";
      magenta = mkC "#A36ac7" "#e0adff";
      cyan = mkC "#02dbdb" "#87fafa";
      white = mkC "#c5c8c6" "#e8e8e1";
    };
  };
}
