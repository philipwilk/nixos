{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options.localDef.programs.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf config.localDef.programs.starship.enable {
    packages = with pkgs; [ starship ];

    xdg.config.files."starship.toml" = {
      generator = (pkgs.formats.toml { }).generate "starship.toml";
      value = {
        format = "$all";
        palette = "catppuccin_latte";
      }
      // lib.importTOML "${
        inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.starship
      }/latte.toml";
    };

    localDef.programs.fish.interactiveInit = ''
       if test "$TERM" != "dumb"
        ${lib.getExe pkgs.starship} init fish | source
      end
    '';
  };
}
