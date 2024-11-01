{ pkgs, lib, ... }:
{
  catppuccin.flavor = "latte";
  catppuccin = {
    enable = true;
    pointerCursor = {
      enable = true;
      accent = "peach";
    };
  };
  programs = {
    starship = {
      enable = true;
      catppuccin.enable = true;
    };
    helix = {
      enable = true;
      catppuccin.enable = true;
    };
    kitty = {
      enable = true;
      catppuccin.enable = true;
      settings.confirm_os_window_close = 0;
    };
    bat = {
      enable = true;
      catppuccin.enable = true;
    };
    bottom = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
