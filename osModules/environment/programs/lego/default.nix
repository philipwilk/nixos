{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lego
  ];
}
