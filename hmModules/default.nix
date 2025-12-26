{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    home = {
      packages = with pkgs; [
        (catppuccin.override {
          accent = "peach";
          variant = "latte";
        })
      ];
    };

    programs.home-manager.enable = true;
    # nix-index-database.comma.enable = true;
    # command-not-found.enable = false;
    # nix-index = {
    # enable = true;
    # enableFishIntegration = true;
    # };

    catppuccin = {
      enable = true;
      flavor = "latte";
      sway.enable = true;
      waybar.enable = true;
    };
  };
}
