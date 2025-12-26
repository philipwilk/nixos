{
  lib,
  inputs,
  ...
}:
{
  hjem = {
    clobberByDefault = true;
    extraModules = lib.filesystem.listFilesRecursive ./programs;
    specialArgs = { inherit inputs; };
    users.philip = {
      directory = "/home/philip";
      user = "philip";
      localDef.programs = {
        bottom.enable = true;
        bat.enable = true;
        carapace.enable = true;
        git.enable = true;
        ssh.enable = true;
        matlab.enable = true;
        openldap.enable = true;
        nix.enable = true;
        direnv.enable = true;
        eza.enable = true;
        skim.enable = true;
        zoxide.enable = true;
        helix.enable = true;
        starship.enable = true;
        gh.enable = true;
        gh-dash.enable = true;
        easyeffects.enable = true;
        fcitx.enable = true;
        kakoune.enable = true;
        fish.enable = true;
        kitty.enable = true;
        fuzzel.enable = true;
        # nix-index.enable = true;
        # nix-index-database / comma
      };
    };
  };
}
