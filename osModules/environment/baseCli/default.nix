{
  pkgs,
  ...
}:
{
  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    shellAliases = {
      grep = "rg";
      tree = "tre";
    };
    systemPackages = with pkgs; [
      eza
      fd
      ripgrep
      ripgrep-all
      tre-command
      wl-clipboard
      wl-clip-persist
      ripunzip
      gparted
      baobab
      traceroute
      bottom
      git
      helix
      zoxide
      bat
      hyfetch

      # list tools
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
    ];
  };

  programs.trippy.enable = true;
}
