{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  options.localDef.programs.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf config.localDef.programs.bat.enable {
    packages = with pkgs; [
      bat
    ];

    xdg.config.files."bat/config".text = ''
      --theme="Catppuccin Latte"
    '';
    xdg.config.files."bat/themmes/Catppuccin Latte.tmTheme".source = "${
      inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.bat
    }/catppuccin Latte.tmTheme";
  };
}
