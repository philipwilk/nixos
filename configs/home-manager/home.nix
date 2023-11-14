{ config
, pkgs
, ...
}:
{
  imports = [ programs/git.nix programs/nys.nix programs/nix.nix ];

  home = {
    username = "philip";
    homeDirectory = "/home/philip";
    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;
  };
}
