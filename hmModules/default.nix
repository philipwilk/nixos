{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./i18n
    ./programs/kakoune
    ./programs/fish
  ];

  config = {
    home = {
      packages = with pkgs; [
        (catppuccin.override {
          accent = "peach";
          variant = "latte";
        })
      ];
    };

    programs = {
      home-manager.enable = true;
      starship.enable = true;
      helix.enable = true;
      nix-index-database.comma.enable = true;
      command-not-found.enable = false;

      eza = {
        enable = true;
        git = true;
        enableFishIntegration = true;
      };

      skim = {
        enable = true;
        enableFishIntegration = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = false;
        settings = {
          git_protocol = "ssh";
        };
      };
      gh-dash = {
        enable = true;
        settings = { };
      };
    };

    catppuccin = {
      enable = true;
      flavor = "latte";
      bat.enable = true;
      bottom.enable = true;
      chromium.enable = true;
      fcitx5.enable = true;
      fish.enable = true;
      fuzzel.enable = true;
      gh-dash.enable = true;
      helix.enable = true;
      kitty.enable = true;
      obs.enable = true;
      sway.enable = true;
      thunderbird.enable = true;
      waybar.enable = true;
    };

    services = {
      easyeffects.enable = true;
    };
  };
}
