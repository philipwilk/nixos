{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options.localDef.programs.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.localDef.programs.helix.enable {
    packages = with pkgs; [ helix ];

    xdg.config.files."helix/config.toml" = {
      generator = (pkgs.formats.toml { }).generate "helix-config.toml";
      value = {
        theme = "catppuccin-latte";
        editor.color-modes = true;
      };
    };

    xdg.config.files."helix/themes/catppuccin-latte.toml".source = "${
      inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.helix
    }/default/catppuccin_latte.toml";
  };
}
