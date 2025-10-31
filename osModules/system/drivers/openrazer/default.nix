{
  pkgs,
  ...
}:
{
  hardware.openrazer = {
    enable = true;
    users = [ "philip" ];
    keyStatistics = true;
  };
  environment.systemPackages = with pkgs; [
    polychromatic
  ];
}
