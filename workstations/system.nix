{
  pkgs,
  agenix,
  config,
  lib,
  nix-matlab,
  nix-your-shell,
  ...
}:
{
  config = lib.mkIf config.workstation.declarativeHome {
    age.secrets.workstation_password.file = ../secrets/workstation_password.age;
    age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];

    boot.kernelParams = [ "net.ipv4.tcp_mtu_probing=1" ];
    boot.kernelModules = [ "sg" ];
    boot.plymouth = {
      themePackages = with pkgs; [ plymouth-blahaj-theme ];
      theme = "blahaj";
    };

    powerManagement.enable = true;
    hardware.opentabletdriver.enable = true;
    hardware.openrazer = {
      enable = true;
      users = [ "philip" ];
      keyStatistics = true;
    };

    nixpkgs.overlays = [
      nix-matlab.overlay
      nix-your-shell.overlays.default
    ];

    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General = {
          ControlPortOverNL80211 = false;
          UseDefaultNetwork = true;
        };
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
          NameResolvingService = "systemd";
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
    systemd.network =
      let
        net = "wlan0";
      in
      {
        enable = true;
        networks.${net} = {
          matchConfig.Name = net;
          networkConfig = {
            DHCP = "yes";
            IgnoreCarrierLoss = 3;
            IPv6PrivacyExtensions = "kernel";
          };
        };
      };

    environment = {
      shells = with pkgs; [ nushell ];
      systemPackages = with pkgs; [
        # Terminals and shells
        kitty
        dash
      ];
      shellAliases = {
        ls = "eza";
        find = "fd";
        grep = "rg";
        tree = "tre";
        cd = "z";
        windows = "systemctl reboot --boot-loader-entry=auto-windows";
        ssh-home = "ssh -A -J fogbox.uk";
        ssh-insecure = "ssh -A -J fogbox.uk -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa";
      };
    };

    users = {
      defaultUserShell = pkgs.nushell;
      users.philip = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
          "adbusers"
          "dialout"
          "libvirtd"
          "video"
          "input"
          "cdrom"
          "optical"
          "plugdev"
        ];
        hashedPasswordFile = config.age.secrets.workstation_password.path;
        packages = with pkgs; [
          # Browsers
          tor-browser-bundle-bin
          qbittorrent
          # Communication
          (discord.override { withOpenASAR = true; })
          slack
          teams-for-linux
          telegram-desktop
          # TTY/serial
          minicom
          heimdall
          ventoy-full
          rkdeveloptool
          usbimager
          syncthing
          # Games
          prismlauncher
          moonlight-qt
          heroic
          bottles
          packwiz
          polychromatic
          # Media creation
          obs-studio
          gimp
          krita
          rawtherapee
          kdenlive
          video-trimmer
          blender
          # Media consumption
          vlc
          jellyfin-media-player
          youtube-music
          # Ripping
          picard
          asunder
          handbrake
          makemkv
          mkvtoolnix
          # Office stuff
          drawio
          matlab
          nextcloud-client
          rnote
          foliate

          # Development
          # Source control
          darcs
          ## Nix
          nixpkgs-review
          direnv
          agenix.packages.x86_64-linux.default
          nixos-generators
          ## Database Management
          dbeaver-bin
          openldap
          apache-directory-studio

          ## Phone stuff
          pmbootstrap

          # Theming
          (catppuccin.override {
            accent = "peach";
            variant = "latte";
          })
        ];
      };
    };

    virtualisation = {
      libvirtd.enable = true;
      podman = {
        enable = true;
        dockerSocket.enable = true;
        dockerCompat = true;
      };
    };
    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = with pkgs; [
          glxinfo
          gamescope
          mangohud
        ];
      };
      virt-manager.enable = true;
    };

    services = {
      fwupd.enable = true;
      logind = {
        powerKey = "poweroff";
        powerKeyLongPress = "reboot";
        lidSwitch = "suspend-then-hibernate";
        lidSwitchExternalPower = "suspend";
      };
      fprintd.enable = true;
      pcscd.enable = true;
      openssh.settings.UseDns = true;
      kanidm.enableClient = true;
      kanidm.clientSettings.uri = "https://testing-idm.fogbox.uk";
      udev.extraRules = ''
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
        SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="256c", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
        SUBSYSTEM=="pci", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
        SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
        KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0666"
      '';
    };
  };
}
