{
  lib,
  config,
  ...
}:
{
  options.localDef.programs.matlab.enable = lib.mkEnableOption "matlab";

  config = lib.mkIf config.localDef.programs.matlab.enable {
    xdg.config.files."matlab/nix.sh".text = ''
      INSTALL_DIR=$HOME/Documents/matlab
    '';
  };
}
