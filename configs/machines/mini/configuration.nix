{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.efi.efiSysMountPoint = "/boot";

  networking = {
    hostName = "mini"; 
    networkmanager.enable = true;
  };

  console.keyMap = "uk";
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  users.users.mini = {
    isNormalUser = true;
    description = "mini";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      helix
      thunderbird
      rustdesk
    ];
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    binsh = "${pkgs.dash}/bin/dash";
  };

  services = {
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
