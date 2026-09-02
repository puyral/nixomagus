{ runCommand, gzip, ... }:

runCommand "gzip-bomb" {
  nativeBuildInputs = [ gzip ];
} ''
  tmp_file="$TMPDIR/bomb.gz"
  out_dir="$out/share"

  mkdir -p "$out_dir"

  # Generate a deliberately huge gzip payload in a temporary file first,
  # then move it into the Nix output directory once the path is ready.
  echo "THIS PATH IS FORBIDDEN" >> "$tmp_file"
  echo "Enjoy the gzibomb !" >> "$tmp_file"
  dd if=/dev/zero bs=1M count=10000 status=none | gzip -9 >> "$tmp_file"
  mv "$tmp_file" "$out_dir/bomb.gz"
''