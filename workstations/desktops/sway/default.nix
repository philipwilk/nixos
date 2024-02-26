{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib.meta) getExe getExe';
  catppuccin = builtins.readFile (pkgs.catppuccin.override { accent = "rosewater"; variant = "latte"; } + "/waybar/latte.css");
  waybar-style = builtins.readFile ./waybar.css;
in
{
  config = lib.mkIf (config.workstation.desktop == "sway") {
    # Nixos config
    security.pam.services = {
      gtklock.fprintAuth = true;
      greetd.fprintAuth = false;
    };

    users.users.philip.packages = with pkgs; [
      # Desktop chore replacements
      loupe
      gnome.nautilus
      gcr
      gnome.seahorse
      wmname
    ];

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
      blueman.enable = true;
      geoclue2 = {
        enable = true;
        enableWifi = true;
        submitData = true;
      };
    };
    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
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



    # Home manager config
    home-manager.users.philip = {
      home.sessionVariables."_JAVA_AWT_WM_NONREPARENTING" = "1";

      programs = {
        waybar = {
          enable = true;
          systemd = {
            enable = true;
            target = "sway-session.target";
          };
          settings.mainbar = {
            layer = "top";
            modules-left = [
              "sway/workspaces"
              "sway/mode"
              "sway/window"
            ];
            modules-center = [
              "clock"
              "mpris"
            ];
            "mpris" = {
              "format" = "{player_icon} {player}: {artist} {title} {position}";
            };
            modules-right = [
              "tray"
              "network"
              "backlight"
              "wireplumber"
              "battery"
            ];
            "wireplumber" = {
              "format" = "{volume}%";
              "format-muted" = "\uf6a9";
              "on-click" = "volumectl toggle-mute";
            };
          };
          style = catppuccin + waybar-style;
        };
        fuzzel.enable = true;
        swaylock.enable = true;
        xplr.enable = true;
      };

      services = {
        avizo.enable = true;
        playerctld.enable = true;
        wlsunset = {
          enable = true;
          latitude = "51.4";
          longitude = "-0.9";
          temperature = {
            day = 6500;
            night = 3700;
          };
        };
        gnome-keyring = {
          enable = true;
          components = [ "pkcs11" "secrets" "ssh" ];
        };
        swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 150;
              command = "${pkgs.gtklock}/bin/gtklock";
            }
            {
              timeout = 300;
              command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
            }
          ];
        };
      };

      home.packages = with pkgs; [
        swaynotificationcenter
        brightnessctl
        pamixer
        gnused
        # SOME SILLY DEVS USE THE GNOME SPECIFIC ICONS INSTEAD OF LIBADWAITA THANKS <3 <3 <3
        gnome.adwaita-icon-theme
        # Appindicator
        libappindicator
        libappindicator-gtk3
      ];

      xdg.userDirs.createDirectories = true;

      wayland.windowManager.sway = {
        enable = true;
        package = pkgs.swayfx;
        catppuccin.enable = true;
        systemd.xdgAutostart = true;
        swaynag.enable = true;
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        config = {
          defaultWorkspace = "workspace number 1";
          modifier = "Mod4";
          terminal = "kitty";
          # ugly, but this fixes most issues, until home-manager adopts environment.d
          startup = [{ command = "${getExe' config.systemd.package "systemctl"} --user import-environment"; }];

          input = {
            "type:keyboard" = {
              xkb_layout = "gb";
              xkb_variant = "colemak";
              xkb_numlock = "enabled";
            };
            "type:pointer" = {
              accel_profile = "flat";
              natural_scroll = "enabled";
            };
            "type:touchpad" = {
              accel_profile = "flat";
              natural_scroll = "enabled";
              tap = "enabled";
              tap_button_map = "lrm";
            };
          };

          bars = [ ];

          window = {
            border = 0;
            hideEdgeBorders = "smart";
          };
          gaps = {
            inner = 8;
          };

          colors = {
            focused = {
              background = "#e6e9ef";
              border = "#e6e9ef";
              text = "#6c6f85";
              indicator = "#e6e9ef";
              childBorder = "#e6e9ef";
            };
            unfocused = {
              background = "#dc8a78";
              border = "#dc8a78";
              text = "#4c4f69";
              indicator = "#dc8a78";
              childBorder = "#dc8a78";
            };
          };

          menu = "${lib.getExe pkgs.fuzzel}";

          output = {
            DP-3 = {
              mode = "3440x1440@144.000Hz";
              adaptive_sync = "on";
            };
          };

          keybindings =
            let
              mod = config.wayland.windowManager.sway.config.modifier;

              #pamixer = lib.getExe pkgs.pamixer;
              #brightnessctl = lib.getExe pkgs.brightnessctl;
              playerctl = lib.getExe pkgs.playerctl;
              grim = lib.getExe pkgs.grim;
              slurp = lib.getExe pkgs.slurp;
            in
            lib.mkOptionDefault {
              # Volume
              "XF86AudioMute" = "exec volumectl toggle-mute";
              "XF86AudioRaiseVolume" = "exec volumectl -u up";
              "XF86AudioLowerVolume" = "exec volumectl -u down";
              # Brightness
              "XF86MonBrightnessDown" = "exec lightctl down";
              "XF86MonBrightnessUp" = "exec lightctl up";
              # Media keys
              "XF86AudioStop" = "exec ${playerctl} stop";
              "XF86AudioPlay" = "exec ${playerctl} play-pause";
              "XF86AudioPause" = "exec ${playerctl} play-pause";
              "XF86AudioNext" = "exec ${playerctl} next";
              "XF86AudioPrev" = "exec ${playerctl} previous";
              # Screenshots
              "Print" = "exec ${grim} -g \"$(${slurp} -d)\" - | wl-copy -t image/png && wl-paste > ~/Pictures/Screenshots/screenshot-$(date).png";
            };
        };
        # Swayfx
        extraConfig = ''
          corner_radius 8
          titlebar_separator disable
          titlebar_border_thickness 0
          shadows enable
      
          bindgesture swipe:right workspace prev
          bindgesture swipe:left workspace next

          exec swaync
          bindsym Mod4+Shift+n exec swaync-client -t -sw
        '';
      };
    };
  };
}
