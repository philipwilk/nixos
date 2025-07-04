{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # original modules
    ./default/nix.nix
    ./default/region.nix

    # replaced modules
    # ./replace/path/to/module.nix
  ];

  config = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
    networking.nftables.enable = true;
    programs.nix-ld.enable = true;
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
        smartmontools
        sg3_utils
        speedtest-go
        dust
        # nix utils
        nix-output-monitor
        nh
        nvd
        bottom
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        NH_FLAKE = lib.mkDefault "/home/philip/repos/nixos";
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
  };
}
