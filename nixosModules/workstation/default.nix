{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./system.nix
    ./iwd.nix
    ./desktops/gnome
    ./desktops/sway
  ];

  options.workstation = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Whether to enable the workstation app suite.
      '';
    };

    desktop = lib.mkOption {
      type = lib.types.enum [
        "gnome"
        "sway"
      ];
      default = "sway";
      example = "gnome";
      description = ''
        Which desktop environment or window manager to enable.
      '';
    };

    i18n.enable = lib.mkEnableOption "IMF/IME input methods";
  };

  config = lib.mkMerge [
    (lib.mkIf config.workstation.i18n.enable {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            fcitx5-gtk
            fcitx5-rime
            fcitx5-hangul
          ];
          settings = {
            addons = {
              pinyin.globalSection.EmojiEnabled = "True";
            };
          };
        };
      };
    })

    (lib.mkIf config.workstation.enable {
      boot.kernelParams = [ "mem_sleep_default=deep" ];

      boot.plymouth = {
        enable = true;
        themePackages = with pkgs; [ nixos-bgrt-plymouth ];
        theme = lib.mkDefault "nixos-bgrt";
      };

      environment = {
        sessionVariables.NIXOS_OZONE_WL = "1";
        binsh = "${pkgs.dash}/bin/dash";
        systemPackages = with pkgs; [
          chromium
          firefox
          thunderbird
          libreoffice

          ## Cli utils
          eza
          fd
          ripgrep
          ripgrep-all
          tre-command
          wl-clipboard
          wl-clip-persist
          networkmanager-openvpn
          ripunzip
          gparted
          baobab
          traceroute

          # Chore replacements
          pavucontrol
          powertop
          nvtopPackages.full
        ];
      };

      programs.fish.enable = true;
      programs.bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };

      services = {
        power-profiles-daemon.enable = true;
        printing.enable = true;
        avahi = {
          enable = true;
          nssmdns4 = true;
          nssmdns6 = true;
          ipv6 = true;
        };
        gnome.gnome-keyring.enable = true;
        flatpak.enable = true;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          wireplumber.enable = true;
        };
        resolved = {
          enable = true;
          dnsovertls = "opportunistic";
          extraConfig = ''
            FallbackDNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net [2620:fe::fe]#dns.quad9.net [2620:fe::9]#dns.quad9.net
          '';
        };
      };
      networking.networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings.General = {
            FastConnectable = true;
            JustWorksRepairing = "always";
            Experimental = true;
          };
        };
      };
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };

      fonts = {
        packages = with pkgs; [
          corefonts
          noto-fonts-emoji-blob-bin
          noto-fonts-emoji
          noto-fonts
          noto-fonts-extra
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          fira-code
          fira-code-symbols
          material-design-icons
        ];
        fontDir.enable = true;
        enableDefaultPackages = true;
        fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [
              "Noto Serif"
              "Noto Serif CJK"
            ];
            sansSerif = [
              "Noto Sans"
              "Noto Sans CJK"
            ];
            emoji = [
              "Blobmoji"
              "Noto Color Emoji"
              "Material Design Icons"
            ];
            monospace = [ "Fira Code" ];
          };
        };
      };
    })
  ];
}
