{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    android-tools
  ];
  programs = {
    kdeconnect.enable = true;
  };
}
