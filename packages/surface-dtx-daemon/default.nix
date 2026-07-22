{
  lib,
  rustPlatform,
  pkg-config,
  dbus,
  surface-dtx-daemon-src,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "surface-dtx-daemon";
  version = "0.3.11";

  src = surface-dtx-daemon-src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "sdtx-0.1.7" = "sha256-ZWaBAt7CPXjbVeSAh57YJnBNkHHMlnjkjaGPB49JSz0=";
      "sdtx-tokio-0.1.7" = "sha256-ZWaBAt7CPXjbVeSAh57YJnBNkHHMlnjkjaGPB49JSz0=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];

  # Build both workspace members
  cargoBuildFlags = [
    "--package"
    "surface-dtx-daemon"
    "--package"
    "surface-dtx-userd"
  ];

  postInstall = ''
    install -Dm644 etc/dtx/surface-dtx-daemon.conf $out/etc/surface-dtx/surface-dtx-daemon.conf
    install -Dm644 etc/dtx/surface-dtx-userd.conf $out/etc/surface-dtx/surface-dtx-userd.conf
    install -Dm755 etc/dtx/attach.sh $out/etc/surface-dtx/attach.sh
    install -Dm755 etc/dtx/detach.sh $out/etc/surface-dtx/detach.sh

    install -Dm644 etc/dbus/org.surface.dtx.conf $out/etc/dbus-1/system.d/org.surface.dtx.conf
    install -Dm644 etc/udev/40-surface_dtx.rules $out/lib/udev/rules.d/40-surface_dtx.rules

    install -Dm644 etc/systemd/surface-dtx-daemon.service $out/lib/systemd/system/surface-dtx-daemon.service
    install -Dm644 etc/systemd/surface-dtx-userd.service $out/lib/systemd/user/surface-dtx-userd.service

    substituteInPlace $out/lib/systemd/system/surface-dtx-daemon.service \
      --replace "/usr/bin/surface-dtx-daemon" "$out/bin/surface-dtx-daemon"
    substituteInPlace $out/lib/systemd/user/surface-dtx-userd.service \
      --replace "/usr/bin/surface-dtx-userd" "$out/bin/surface-dtx-userd"
  '';

  meta = with lib; {
    description = "Linux User-Space Detachment System (DTX) Daemons for the Surface ACPI Driver";
    homepage = "https://github.com/linux-surface/surface-dtx-daemon";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
