{ config, pkgs, lib, ... }: {
  config = lib.mkIf (config.workstation.desktop == "gnome") {
    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome.geary
        gnome.totem
        gnome.yelp
        gnome-text-editor
        gnome.gnome-software
      ];
      systemPackages = with pkgs; [
        # Gnome extensions
        gnomeExtensions.appindicator
        gnomeExtensions.forge
        gnomeExtensions.just-perfection
        gnomeExtensions.rounded-window-corners
        gnomeExtensions.search-light
        gnomeExtensions.duckduckgo-search-provider
        gnomeExtensions.fuzzy-app-search
        gnome.gnome-tweaks
      ];
    };

    services = {
      libinput.mouse.accelProfile = "flat";
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        excludePackages = with pkgs; [ xterm ];
      };
    };
  };
}
