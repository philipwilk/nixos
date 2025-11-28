{
  ...
}:
{
  nixpkgs.overlays = [
    # add cpu monitoring option
    (import ./hddfancontrol)

    (import ./searxng)
  ];
}
