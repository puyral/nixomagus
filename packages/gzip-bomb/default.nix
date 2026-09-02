{ runCommand, gzip, zstd, ... }:

runCommand "gzip-bomb" {
  nativeBuildInputs = [ gzip zstd ];
} ''
  out_dir="$out/share"
  mkdir -p "$out_dir"

  # Legacy gzip fallback: still tiny on the wire, but absurdly large once
  # expanded by the client.
  dd if=/dev/zero bs=1M count=10000 status=none | gzip -9 > "$out_dir/bomb.gz"

  # Modern zstd path: much stronger compression ratio, so this is the nasty
  # super-bomb for clients that advertise zstd support.
  dd if=/dev/zero bs=1M count=100000 status=none | zstd -19 -T0 --no-progress -q -o "$out_dir/bomb.zstd"
''