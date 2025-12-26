{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  options.localDef.programs.bottom.enable = lib.mkEnableOption "bottom";

  config = lib.mkIf config.localDef.programs.bottom.enable {
    packages = with pkgs; [ bottom ];

    xdg.config.files."bottom/bottom.toml" = {
      generator = (pkgs.formats.toml { }).generate "bottom.toml";
      value = lib.importTOML "${
        inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.bottom
      }/latte.toml";
    };
  };
}
