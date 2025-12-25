{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.localDef.programs.carapace.enable = lib.mkEnableOption "carapace";

  config = lib.mkIf config.localDef.programs.carapace.enable {
    packages = with pkgs; [
      carapace
    ];
  };
}
