{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.localDef.programs.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf config.localDef.programs.bat.enable {
    packages = with pkgs; [
      bat
    ];
  };
}
