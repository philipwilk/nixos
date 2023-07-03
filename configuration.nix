# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amd_pstate=guided" ];

  # Enable tablet driver
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
    SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  networking.hostName = "nixowos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Send mouse acceleration to the abyss
  services.xserver.libinput.mouse.accelProfile = "flat";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Remove gnome apps
  #services.gnome.core-utilities.enable = false;
  # Remove certain gnome apps
  environment.gnome.excludePackages = (with pkgs; [
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
  ]);

  # Yeet xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Run Nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d --delete-older-than 14d";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "colemak";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philip = {
    isNormalUser = true;
    description = "philip";
    extraGroups = [ "networkmanager" "wheel" "i2c" "corectrl" "adbusers" ];
    packages = with pkgs; [
      firefox-devedition
      #ddcutil
      neofetch
      via

      # Media manipulation
      obs-studio
      gimp
      krita
      rawtherapee
      vlc
      ardour

      # Game
      prismlauncher
      mangohud
      steam

      # Gnome extensions
      gnomeExtensions.gsconnect
      gnomeExtensions.gsnap
      gnomeExtensions.appindicator
      gnomeExtensions.emoji-selector
      gnome.gnome-tweaks

      # Development
      ## Editors 
      unstable.vscode
      lapce
      helix
      ## Git
      git
      gh
      ## Others
      direnv
      rpi-imager
      alejandra
      nixfmt
      nixpkgs-fmt
      flashrom
      dbeaver
      nixpkgs-review
      yubikey-touch-detector

      # Android
      heimdall
      pmbootstrap
    ];
  };

  # Enable virtualisation w/ podman
  virtualisation.podman.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # steam firewall settings
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];
  # Enable opencl on my amd graphics cards
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    vaapiVdpau
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  #programs.mtr.enable = true;
  services.pcscd.enable = true;
  #programs.gnupg.agent = {
  #  enableSSHSupport = true;
  #};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Enable flatpak
  services.flatpak.enable = true;

  # Enable auto upgrade
  system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = true;

  # nixos experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Update cpu microcode
  hardware.cpu.amd.updateMicrocode = true;
  # enable amd sev device
  hardware.cpu.amd.sev.enable = true;
  # enable opencl on amd
  services.xmr-stak.openclSupport = true;

  # enable corctrl
  programs.corectrl.enable = true;
  programs.corectrl.gpuOverclock.ppfeaturemask = "0xffffffff";
  programs.corectrl.gpuOverclock.enable = true;

  # Cpu governor
  powerManagement.cpuFreqGovernor = "ondemand";

  # Enable wayland "support"
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable fast bluetooth pairing
  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      ReconnectAttempts = 7;
      ReconnectIntervals = "1, 2, 3";
    };
  };

  services.openssh.settings = {
    extraConfig = "+PubkeyAuthOptions verify-required+";
  };
}
