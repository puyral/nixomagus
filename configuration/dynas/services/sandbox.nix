{
  networking.nginx.instances."pi" = {
    enable = true;
    subdomain = "pi.dynas";
    port = 9456;
    address = "sandbox.local";
  };
}
