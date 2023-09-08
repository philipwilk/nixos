{ pkgs
, agenix
, config
, ...
}: {
  age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
  age.secrets.workstation_password.file = ../secrets/workstation_password.age;

  hardware = {
    opentabletdriver.enable = true;
    pulseaudio.enable = false;
  };
  security.rtkit.enable = true;

  networking.networkmanager.enable = true;

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    gnome.excludePackages = with pkgs; [
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
    shells = with pkgs; [
      unstable.fish
    ];
    binsh = "${pkgs.dash}/bin/dash";
    systemPackages = with pkgs; [
      # Terminals and shells
      unstable.kitty
      dash
      # Global editor
      unstable.helix
    ];
  };

  users = {
    defaultUserShell = pkgs.unstable.fish;
    users.philip = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "adbusers" "dialout" ];
      passwordFile = config.age.secrets.workstation_password.path;
      packages = with pkgs; [
      # Browsers
      firefox-devedition
      tor-browser-bundle-bin
      qbittorrent
      # Communication
      (unstable.discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      unstable.thunderbird
      minicom
      heimdall
      # Games
      prismlauncher
      unstable.xivlauncher
      # Media creation
      obs-studio
      gimp
      krita
      rawtherapee
      ardour
      # Media consumption
      vlc
      
      # Development
      ## Editors
      unstable.vscode
      ## Github auth manager
      gh
      ## Nix
      unstable.nixpkgs-review
      direnv
      agenix.packages.x86_64-linux.default
      ## Database Management
      dbeaver

      # Gnome extensions
      gnomeExtensions.appindicator
      gnomeExtensions.emoji-selector
      gnomeExtensions.vitals
      gnomeExtensions.forge
      gnomeExtensions.just-perfection
      gnomeExtensions.rounded-window-corners
      gnome.gnome-tweaks

      # Misc
      neofetch
      ];
    };
  };

  virtualisation.podman.enable = true;

  programs = {
    fish.enable = true;
    adb.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  services = {
    xserver = {
      enable = true;
      libinput.mouse.accelProfile = "flat";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = with pkgs; [ xterm ];
      xkbVariant = "colemak";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
    flatpak.enable = true;
    pcscd.enable = true;
    openssh.settings.extraConfig = "+PubkeyAuthOptions verify-required+";
    udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="256c", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
      SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0666"
    '';
  };

  fonts = {
    fonts = with pkgs; [
      corefonts
      noto-fonts-emoji-blob-bin
      noto-fonts-emoji
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      fira-code
      fira-code-symbols
    ];
    fontDir.enable = true;
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Serif CJK" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK" ];
        emoji = [ "Blobmoji" "Noto Color Emoji" ];
        monospace = [ "Fira Code" ];
      };
    };
  };
}
