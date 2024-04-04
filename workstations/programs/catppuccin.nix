{ pkgs, lib, ... }: {
  catppuccin.flavour = "latte";
  gtk.catppuccin = {
    enable = true;
    cursor = {
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
