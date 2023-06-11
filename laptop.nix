# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  unstable = import <nixos-unstable> {config = config.nixpkgs.config;};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nixowos-d-hell"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  # Disable mouse accel
  services.xserver.libinput.mouse.accelProfile = "flat";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Remove certain gnome apps
  environment.gnome.excludePackages = with pkgs; [
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

  # Yeet xterm
  services.xserver.excludePackages = [pkgs.xterm];

  # Run Nix garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Firefox nightly overlay
  nixpkgs.overlays =
  let
    # Change this to a rev sha to pin
    moz-rev = "master";
    moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
    nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
  in [
    nightlyOverlay
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philip = {
    isNormalUser = true;
    description = "philip";
    extraGroups = ["networkmanager" "wheel" "input" "dialout"];
    packages = with pkgs; [
      latest.firefox-nightly-bin
      armcord
      neofetch
      hw-probe

      # Media manipulation
      obs-studio
      gimp
      krita
      rawtherapee
      vlc

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
      unstable.vscode
      git
      direnv
      rpi-imager
      alejandra
      nixfmt
      nixpkgs-fmt
      flashrom
      gh
      minicom
      vim
      emacs
      nixpkgs-review

      # Android
      heimdall
      pmbootstrap

      # Gpg keys
      gnupg
      pinentry-gnome
    ];
  };

  # steam firewall settings
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable virtualisation w/ podman
  virtualisation.podman.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "philip";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Nixos enable roation
  hardware.sensor.iio.enable = true;
  
  # Tlp power management daemon
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  # "Deep" sleep to MEMORY NOT IDLE
  boot.kernelParams = [ "mem_sleep_default=deep" ];
}
