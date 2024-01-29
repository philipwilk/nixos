{ config
, pkgs
, ...
}:
{
  imports = [
    programs/git.nix
    programs/nys.nix
    programs/nix.nix
    programs/zoxide.nix
    programs/virtman.nix
    programs/ssh.nix
    programs/easyeffects.nix
  ];

  home = {
    username = "philip";
    homeDirectory = "/home/philip";
    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;
  };
}
