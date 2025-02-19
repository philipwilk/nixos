{
  lib,
  pkgs,
  config,
  catppuccin,
  ...
}:
let
  join-dirfile = dir: map (file: ./${dir}/${file}.nix);
in
{
  imports =
    [
      ./system.nix
      ./desktops/gnome
      ./desktops/sway
    ]
    ++ join-dirfile "programs" [
      "git"
      "mercurial"
      "i18n"
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
    declarativeHome = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Whether to enable the use of home-manager to manage configs.
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

    sourceControl = {
      userName = lib.mkOption {
        type = lib.types.str;
        default = "Philip Wilk";
        example = "Joe Bloggs";
      };
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "p.wilk@student.reading.ac.uk";
        example = "joe.bloggs@example.com";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.workstation.declarativeHome {
      workstations.i18n.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.philip = {
          imports =
            [ catppuccin.homeManagerModules.catppuccin ]
            ++ join-dirfile "programs" [
              "nys"
              "direnv"
              "nix"
              "zoxide"
              "virtman"
              "ssh"
              "catppuccin"
              "ldap"
              "kakoune/default"
              "matlab"
              "nushell"
            ];

          home = {
            username = "philip";
            homeDirectory = "/home/philip";
            stateVersion = "24.05";
          };
          programs.home-manager.enable = true;
        };
      };
    })
    (lib.mkIf config.workstation.enable {
      boot.kernelParams = [ "mem_sleep_default=deep" ];

      environment = {
        sessionVariables.NIXOS_OZONE_WL = "1";
        binsh = "${pkgs.dash}/bin/dash";
        systemPackages = with pkgs; [
          chromium
          firefox
          thunderbird
          rustdesk-flutter
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

          # Chore replacements
          pavucontrol
          powertop
        ];
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
          dnssec = "true";
          dnsovertls = "true";
          domains = [ "~." ];
          extraConfig = ''
            DNS=1.1.1.1#cloudflare-dns.com [2606:4700:4700::1111]#cloudflare-dns.com
            FallbackDNS=9.9.9.9#dns.quad9.net [2620:fe::fe]#dns.quad9.net
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
