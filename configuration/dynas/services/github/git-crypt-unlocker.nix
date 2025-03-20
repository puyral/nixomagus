{ writeScriptBin, gnupg, git-crypt, coreutils }:

{
  name = "git-crypt-unlocker";

  buildInputs = [
    gnupg
    git-crypt
    coreutils
  ];

  src = writeScriptBin "git-crypt-unlocker" ''
    #!/usr/bin/env bash

    echo "$GPG_PRIVATE_KEY" | ${coreutils}/bin/base64 -d > /tmp/git-crypt-key.asc

    ${gnupg}/bin/gpg --batch --import /tmp/git-crypt-key.asc

    ${gnupg}/bin/gpgconf --kill gpg-agent

    ${gnupg}/bin/gpg-agent --daemon --allow-preset-passphrase --max-cache-ttl 3153600000

    ${gnupg}/libexec/gpg-preset-passphrase --preset --passphrase "$GPG_KEY_PASS" "$GPG_KEY_GRIP"

    ${git-crypt}/bin/git-crypt unlock

    ${coreutils}/bin/rm /tmp/git-crypt-key.asc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/git-crypt-unlocker
    chmod +x $out/bin/git-crypt-unlocker
  '';
}