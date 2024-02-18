{ config
, pkgs
, lib
, ...
}:
{
  config = lib.mkIf (config.workstation.desktop == "gnome") {

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-photos
      gnome.gnome-maps
      gnome.geary
      epiphany
      gnome.gnome-weather
      gnome.gnome-contacts
      gnome.totem
      gnome.cheese
      gnome.gnome-calendar
      gnome.yelp
      gnome-text-editor
      gnome.gnome-music
      gnome.gnome-software
      gnome-console
    ];

    users.users.philip.packages = with pkgs; [
      # Gnome extensions
      gnomeExtensions.appindicator
      gnomeExtensions.emoji-selector
      gnomeExtensions.forge
      gnomeExtensions.just-perfection
      gnomeExtensions.rounded-window-corners
      gnomeExtensions.search-light
      gnomeExtensions.duckduckgo-search-provider
      gnomeExtensions.fuzzy-app-search
      gnome.gnome-tweaks
    ];


    services = {
      gnome.gnome-keyring.enable = true;
      xserver = {
        enable = true;
        libinput.mouse.accelProfile = "flat";
        displayManager = {
          gdm.enable = true;
          autoLogin = {
            user = "philip";
            enable = true;
          };
        };
        desktopManager.gnome.enable = true;
        excludePackages = with pkgs; [ xterm ];
        xkb.variant = "colemak";
      };
    };
  };
}
