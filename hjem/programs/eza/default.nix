{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.localDef.programs.eza.enable = lib.mkEnableOption "eza";

  config = lib.mkIf config.localDef.programs.eza.enable {
    packages = with pkgs; [ eza ];
  };
}
