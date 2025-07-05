{
  config,
  lib,
  pkgs,
  ...
}:
let
in
{
  config = lib.mkIf (config.workstation.desktop == "sway") {
    # Nixos config
    security.pam.services = {
      greetd.fprintAuth = false;
    };

    services = {
      greetd = {
        enable = true;
        package = pkgs.greetd.tuigreet;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
          };
        };
      };
      geoclue2 = {
        enable = true;
        enableWifi = true;
        submitData = true;
      };
      gvfs.enable = true;
      udisks2.enable = true;
    };
    programs.gnome-disks.enable = true;
    programs.dconf.enable = true;

    xdg.portal = {
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    # https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
