{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea
    bruno
    darcs
    mdcat
  ];
}
