{
  # Client ids and password hashes (safe at rest, they land in the authelia
  # config file in the store anyway). The plaintext client secrets live in
  # ./secrets.sops-secret.yaml.
  headscale = {
    id = "vNpmkADXpR6cG7m0CZvt~tCNkw55FeIFp.W1qV3LlW4dALyq1~RV2bcL-j22B3CjKQokLfMa";
    hashed = "$pbkdf2-sha512$310000$S045Nn0kiaKdwZOC6Ufovg$Vs2zmKb8syTXBhEFIuGx1IhTpkNph81xLQtYUhKYWrEH8FFkiN9f9Jci8EHDtNXG9cuTIEUn97vC.3fMo6vcPw";
  };
  headplane = {
    id = "84a6TZ24056AZ_EtyWdFzvtQuKL2D4aKtfPCRMxVOTOelAMpQ7RwaGqi0TuXvz0GgK1PM2~z";
    hashed = "$pbkdf2-sha512$310000$8.MDvEu6nA/srhoX4hBFqA$DJw2lPOAoGeUAf2dnSnTqsvHXHecP/UJ4rqzKSIOQE8s.kRzQGKEpFmW30lCkG8rbIT1y1S5wlimA51hGOIzjA";
  };
}
