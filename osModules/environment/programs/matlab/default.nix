{
  pkgs,
  nix-matlab,
  ...
}:
{
  nixpkgs.overlays = [
    nix-matlab.overlay
  ];

  environment.systemPackages = with pkgs; [
    matlab
  ];
}
