{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    picard
    asunder
    handbrake
    makemkv
    mkvtoolnix
  ];
}
