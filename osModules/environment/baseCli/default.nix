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
      ripunzip
      parted
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
      nix-tree
    ];
  };

  programs.trippy.enable = true;
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    shortcut = "s";
    escapeTime = 0;
    extraConfig = ''
      set -g mouse on

      unbind C-[
    '';
  };
}
