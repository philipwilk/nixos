{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (octodns.withProviders (ps: [
      octodns-providers.desec
      octodns-providers.bind
    ]))
  ];
}
