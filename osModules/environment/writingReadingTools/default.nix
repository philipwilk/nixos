{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libreoffice
    drawio
    rnote
    foliate
  ];
}
