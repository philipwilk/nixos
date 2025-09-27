{
  pkgs,
  ...
}:
{
  hjem.users.philip = {
    packages = with pkgs; [
      bat
    ];
  };
}
