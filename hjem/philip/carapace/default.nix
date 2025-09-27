{
  pkgs,
  ...
}:
{
  hjem.users.philip.packages = with pkgs; [
    carapace
  ];
}
