{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    prismlauncher
    moonlight-qt
    heroic
    bottles
    packwiz
  ];
}
