{...}:{

    enumerate =
      with builtins;
      l:
      let
        f =
          acc: e:
          [
            {
              idx = length acc;
              value = e;
            }
          ]
          ++ acc;
      in
      foldl' f [ ] l;

}