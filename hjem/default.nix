{
  lib,
  ...
}:
{
  hjem = {
    clobberByDefault = true;
    extraModules = lib.filesystem.listFilesRecursive ./programs;
    users.philip = {
      directory = "/home/philip";
      user = "philip";
      localDef.programs = {
        bottom.enable = true;
        bat.enable = true;
        carapace.enable = true;
        git.enable = true;
      };
    };
  };
}
