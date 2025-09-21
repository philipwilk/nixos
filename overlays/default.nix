{
  ...
}:
{
  nixpkgs.overlays = [
    # desec provider
    (import ./octodns/providers/desec)
  ];
}
