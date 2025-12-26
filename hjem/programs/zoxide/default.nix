{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.localDef.programs.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf config.localDef.programs.zoxide.enable {
    packages = with pkgs; [ zoxide ];

    localDef.programs.fish.interactiveInit = "${lib.getExe pkgs.zoxide} init fish | source";
  };
}
