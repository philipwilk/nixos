{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options.localDef.programs.gh-dash.enable = lib.mkEnableOption "gh-dash";

  config = lib.mkIf config.localDef.programs.gh-dash.enable {
    packages = with pkgs; [ gh-dash ];

    xdg.config.files."gh-dash/config.yml".source = "${
      inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.gh-dash
    }/latte/catppuccin-latte-peach.yml";
  };
}
