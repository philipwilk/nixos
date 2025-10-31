{
  pkgs,
  lib,
  ...
}:
{
  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [ nixos-bgrt-plymouth ];
    theme = lib.mkDefault "nixos-bgrt";
  };
}
