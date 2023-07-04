{ pkgs
, ...
}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

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
    ];
  };

  users.users.philip = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "dialout" ];
    packages = with pkgs; [
      firefox-devedition
      neofetch
      minicom

      # Media manipulation
      obs-studio
      gimp
      krita
      rawtherapee
      vlc
      ardour

      # Games
      prismlauncher

      # Gnome extensions
      gnomeExtensions.gsconnect
      gnomeExtensions.gsnap
      gnomeExtensions.appindicator
      gnomeExtensions.emoji-selector
      gnomeExtensions.vitals
      gnome.gnome-tweaks

      # Development
      ## Editors
      unstable.vscode
      lapce
      helix
      ## Git
      git
      gh
      ## Nix
      nixpkgs-fmt
      nixpkgs-review
      nil
      direnv
      ## Databases
      dbeaver
      ## Others
      rpi-imager
      yubikey-touch-detector
      ## Android
      heimdall
      pmbootstrap

    ];
  };

  virtualisation.podman.enable = true;

  programs = {
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
    printing.enable = true;
    flatpak.enable = true;
    pcscd.enable = true;
    openssh.settings.extraConfig = "+PubkeyAuthOptions verify-required+";
    udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
      SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };
}
