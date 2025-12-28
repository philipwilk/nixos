{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea-community-src
    bruno
    darcs
    mdcat
  ];
}
