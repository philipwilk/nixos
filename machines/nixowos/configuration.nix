{ inputs
, lib
, config
, pkgs
, ...
}: {
  imports = [ ./hardware-configuration.nix ];

  nixpkgs = {
    overlays = [ ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes auto-allocate-uids ca-derivations";
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d --delete-older-than 14d";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "amd_pstate=guided" ];
  };

  networking = {
    hostName = "nixowos";
    networkmanager.enable = true;
  };
  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  system.autoUpgrade.enable = true;
  hardware = {
    cpu.amd = {
      updateMicrocode = true;
      sev.enable = true;
    };
    bluetooth.settings.General = {
      FastConnectable = true;
      ReconnectAttempts = 7;
      ReconnectIntervals = "1, 2, 3";
    };
    opentabletdriver.enable = true;
    pulseaudio.enable = false;
  };
  security.rtkit.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

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

  console.keyMap = "uk";

  users.users = {
    philip = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "i2c" "corectrl" "adbusers" ];
      packages = with pkgs; [
        firefox-devedition
        neofetch
        via

        # Media manipulation
        obs-studio
        gimp
        krita
        rawtherapee
        vlc
        ardour

        # Games
        prismlauncher
        mangohud

        # Gnome extensions
        gnomeExtensions.gsconnect
        gnomeExtensions.gsnap
        gnomeExtensions.appindicator
        gnomeExtensions.emoji-selector
        gnome.gnome-tweaks

        # Development
        ## Editors
        vscode
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

        ## Others
        rpi-imager
        flashrom
        dbeaver
        yubikey-touch-detector

        # Android
        heimdall
        pmbootstrap
      ];
    };
  };

  virtualisation.podman.enable = true;
  programs = {
    adb.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    corectrl = {
      enable = true;
      gpuOverclock = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
    };
  };

  services = {
    xserver = {
      enable = true;
      libinput.mouse.accelProfile = "flat";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = with pkgs; [ xterm ];
      layout = "gb";
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

  system.stateVersion = "23.05";
}
