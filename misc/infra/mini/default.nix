{ config, pkgs, ... }: 
let
  pc =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [ pc laptop ];
in
{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "mini";
    networkmanager.enable = true;
  };

  console.keyMap = "uk";
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  users.users = {
    philip = {
      openssh.authorizedKeys.keys = workstations;
      isNormalUser = true;
      description = "philip";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox
        helix
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
      ];
    };
    mini = {
      isNormalUser = true;
      description = "mini";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox
        helix
        thunderbird
        rustdesk-flutter
        libreoffice
        chromium
      ];
    };
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    binsh = "${pkgs.dash}/bin/dash";
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    xserver = {
      enable = true;
      libinput.mouse.accelProfile = "flat";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = with pkgs; [ xterm ];
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
    ];
    fontDir.enable = true;
    enableDefaultPackages = true;
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

  system.stateVersion = "24.05";
}
