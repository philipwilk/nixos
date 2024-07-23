{
  nixpkgs,
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs = {
    # overlays = let
    #   overlay = _: _: {
    #     unstable = import nixpkgs-unstable {
    #       system = "x86_64-linux";
    #       inherit (config.nixpkgs) config;
    #     };
    #   };
    # in [ overlay ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    # registry = lib.mapAttrs (_: value: { flake = value; }) {
    #   inherit nixpkgs nixpkgs-unstable;
    # };
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

  environment = {
    systemPackages = with pkgs; [
      git
      helix
      # cli utils
      hyfetch
      usbutils
      pciutils
      libva-utils
      dnsutils
      dmidecode
      sbctl
      # nix utils
      nix-output-monitor
      nh
      nvd
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      FLAKE = lib.mkDefault "/home/philip/repos/nixconf";
    };
  };

  # Ensure firmware is available
  hardware = {
    enableAllFirmware = true;
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
