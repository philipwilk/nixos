{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.localDef.programs.easyeffects.enable = lib.mkEnableOption "easyeffects";

  config = lib.mkIf config.localDef.programs.easyeffects.enable {
    packages = with pkgs; [ easyeffects ];
  };
}
