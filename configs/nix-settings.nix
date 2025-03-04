{
  nixpkgs,
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [ nixos-bgrt-plymouth ];
    theme = lib.mkDefault "nixos-bgrt";
  };

  nix = {
    package = pkgs.nixVersions.latest;
    registry = lib.mapAttrs (_: value: { flake = value; }) {
      inherit nixpkgs;
    };
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes auto-allocate-uids ca-derivations";
      auto-optimise-store = true;
      substituters = [ "https://cache.fogbox.uk" ];
      trusted-public-keys = [ "cache.fogbox.uk:lwlsX4TZdJXQzfqTWRMf/I8xTlR/i+B5RTkD2BQhzdA=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d --delete-older-than 14d";
      persistent = true;
    };
  };

  networking.nftables.enable = true;

  environment = {
    systemPackages = with pkgs; [
      git
      helix
      zoxide
      bat
      # cli utils
      hyfetch
      usbutils
      pciutils
      libva-utils
      dnsutils
      dmidecode
      sbctl
      ethtool
      wireguard-tools
      lm_sensors
      # nix utils
      nix-output-monitor
      nh
      nvd
      bottom
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      FLAKE = lib.mkDefault "/home/philip/repos/nixos";
    };
  };

  # Ensure firmware is available
  hardware = {
    cpu = {
      amd = {
        updateMicrocode = true;
        sev.enable = true;
        sevGuest.enable = true;
      };
      intel = {
        updateMicrocode = true;
        sgx.provision.enable = true;
      };
    };
  };

  system = {
    autoUpgrade.enable = true;
    stateVersion = lib.mkDefault "23.05";
  };
}
