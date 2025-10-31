{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nixpkgs-review
    direnv
  ];
}
