{ pkgs, agenix, config, lib, nix-matlab, nix-your-shell, ... }: {
  config = lib.mkIf config.workstation.declarativeHome {
    age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
    age.secrets.workstation_password.file = ../secrets/workstation_password.age;

    powerManagement.enable = true;
    hardware.opentabletdriver.enable = true;

    nixpkgs.overlays = [ nix-matlab.overlay nix-your-shell.overlays.default ];

    environment = {
      sessionVariables.FLAKE = "/home/philip/repos/nixconf";
      shells = with pkgs; [ nushellFull ];
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
        ssh-home = "ssh -A -J bastion.fogbox.uk:22420";
        ssh-insecure = "ssh -A -J bastion.fogbox.uk:22420 -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa";
      };
    };

    users = {
      defaultUserShell = pkgs.nushellFull;
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
        ];
        hashedPasswordFile = config.age.secrets.workstation_password.path;
        packages = with pkgs; [
          # Browsers
          tor-browser-bundle-bin
          qbittorrent
          # Communication
          (discord.override {
            withOpenASAR = true;
          })
          slack
          # TTY/serial
          minicom
          heimdall
          # Games
          prismlauncher
          moonlight-qt
          heroic
          packwiz
          # Media creation
          obs-studio
          gimp
          krita
          rawtherapee
          ardour
          kdenlive
          video-trimmer
          picard
          sound-juicer
          blender-hip
          # Media consumption
          vlc
          lollypop
          youtube-music
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
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      virt-manager.enable = true;
    };

    services = {
      logind = {
        powerKey = "poweroff";
        powerKeyLongPress = "reboot";
        lidSwitch = "suspend-then-hibernate";
        lidSwitchExternalPower = "suspend";
      };
      fprintd.enable = true;
      pcscd.enable = true;
      openssh = {
        extraConfig = "+PubkeyAuthOptions touch-required+";
        settings.UseDns = true;
      };
      udev.extraRules = ''
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
        SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="256c", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
        SUBSYSTEM=="pci", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
        SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
        KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0666"
      '';
    };

    # Keyboard ime support
    # i18n.inputMethod = {
      # enabled = "fcitx5";
    #   fcitx5 = {
    #     waylandFrontend = true;
    #     addons = with pkgs; [ fcitx5-gtk fcitx5-rime fcitx5-hangul ];
    #     settings = { addons = { pinyin.globalSection.EmojiEnabled = "True"; }; };
    #   };
    # };
  };
}
