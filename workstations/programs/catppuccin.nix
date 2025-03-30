{ pkgs, lib, ... }:
{
  catppuccin.flavor = "latte";
  catppuccin = {
    enable = true;
    pointerCursor = {
      enable = true;
      accent = "peach";
    };
    bat.enable = true;
    bottom.enable = true;
    chromium.enable = true;
    fcitx5.enable = true;
    fish.enable = true;
    fuzzel.enable = true;
    gh-dash.enable = true;
    gtk.enable = true;
    helix.enable = true;
    kitty.enable = true;
    obs.enable = true;
    sway.enable = true;
    thunderbird.enable = true;
    waybar.enable = true;
  };
}
