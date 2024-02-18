{ pkgs
, agenix
, config
, nix-matlab
, nix-your-shell
, ...
}: {
  age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
  age.secrets.workstation_password.file = ../secrets/workstation_password.age;

  powerManagement.enable = true;
  hardware = {
    opentabletdriver.enable = true;
    pulseaudio.enable = false;
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

  networking.networkmanager.enable = true;

  nixpkgs.overlays = [ nix-matlab.overlay nix-your-shell.overlays.default ];

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shells = with pkgs; [
      nushellFull
    ];
    binsh = "${pkgs.dash}/bin/dash";
    systemPackages = with pkgs; [
      # Terminals and shells
      kitty
      dash
      # Global editor
      helix
    ];
    shellAliases = {
      ls = "eza";
      find = "fd";
      grep = "rg";
      tree = "tre";
      cd = "z";
    };
  };

  users = {
    defaultUserShell = pkgs.nushellFull;
    users.philip = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "adbusers" "dialout" "libvirtd" "video" "input" ];
      hashedPasswordFile = config.age.secrets.workstation_password.path;
      packages = with pkgs; [
        # Browsers
        firefox-devedition
        google-chrome
        tor-browser-bundle-bin
        qbittorrent
        # Communication
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
        thunderbird
        slack
        # TTY/serial
        minicom
        heimdall
        rustdesk-flutter
        # Games
        prismlauncher
        xivlauncher
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
        # Office stuff
        libreoffice
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
        ## Database Management
        dbeaver
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
        ## Phone stuff
        pmbootstrap

        # Chore replacements
        pavucontrol
        powertop

        # Misc
        neofetch
        usbutils
        pciutils
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
    gnome.gnome-keyring.enable = true;
    fprintd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    printing.enable = true;
    flatpak.enable = true;
    pcscd.enable = true;
    auto-cpufreq.enable = true;
    openssh.settings.extraConfig = "+PubkeyAuthOptions touch-required+";
    udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="256c", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
      SUBSYSTEM=="pci", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
      SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0666"
    '';
  };

  fonts = {
    packages = with pkgs.unstable; [
      corefonts
      noto-fonts-emoji-blob-bin
      noto-fonts-emoji
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      fira-code
      fira-code-symbols
      font-awesome_6
    ];
    fontDir.enable = true;
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Serif CJK" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK" ];
        emoji = [ "Blobmoji" "Noto Color Emoji" "Font Awesome 6 Free" ];
        monospace = [ "Fira Code" ];
      };
    };
  };

  # Keyboard ime support
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
      hangul
    ];
  };
}
