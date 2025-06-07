{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.workstation.desktop == "gnome") {
    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
        geary
        totem
        yelp
        gnome-text-editor
        gnome-software
        epiphany
      ];
      systemPackages = with pkgs; [
        # Gnome extensions
        gnomeExtensions.appindicator
        gnomeExtensions.forge
        gnomeExtensions.just-perfection
        gnomeExtensions.search-light
        gnomeExtensions.duckduckgo-search-provider
        gnomeExtensions.fuzzy-app-search
        gnome-tweaks
      ];
    };

    services = {
      libinput.mouse.accelProfile = "flat";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xserver.excludePackages = with pkgs; [ xterm ];
    };
  };
}
