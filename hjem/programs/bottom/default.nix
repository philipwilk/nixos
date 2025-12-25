{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.localDef.programs.bottom.enable = lib.mkEnableOption "bottom";

  config = lib.mkIf config.localDef.programs.bottom.enable {
    packages = with pkgs; [ bottom ];
  };
}
