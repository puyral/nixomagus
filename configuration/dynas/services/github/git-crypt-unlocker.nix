{
  writeShellApplication,
  gnupg,
  git-crypt,
  coreutils,
  pinentry-tty,
  ...
}:

writeShellApplication {
  name = "git-crypt-unlocker";

  runtimeInputs = [
    gnupg
    git-crypt
    coreutils
    pinentry-tty
  ];

  text = ''
    echo "$GPG_PRIVATE_KEY" | base64 -d > /tmp/git-crypt-key.asc

    gpg --batch --import /tmp/git-crypt-key.asc

    gpgconf --kill gpg-agent

    gpg-agent --daemon --allow-preset-passphrase --max-cache-ttl 3153600000

    ${gnupg}/libexec/gpg-preset-passphrase --preset --passphrase "$GPG_KEY_PASS" "$GPG_KEY_GRIP"

    git-crypt unlock

    rm /tmp/git-crypt-key.asc
  '';
}
