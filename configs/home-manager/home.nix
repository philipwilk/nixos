{ config
, pkgs
, ...
}:
{
  imports =
    let
      join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
    in
    join-dirfile "programs" [
      "git"
      "nys"
      "nix"
      "zoxide"
      "virtman"
      "ssh"
      "easyeffects"
    ] ++
    join-dirfile "de" [
      "swayfx"
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
