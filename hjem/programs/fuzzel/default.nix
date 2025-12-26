{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{

  options.localDef.programs.fuzzel.enable = lib.mkEnableOption "fuzzel";

  config = lib.mkIf config.localDef.programs.fuzzel.enable {
    xdg.config.files."fuzzel/fuzzel.ini" = {
      generator = lib.generators.toINI { };
      value = {
        main = {
          exit-on-keyboard-focus-loss = false;
          terminal = "${lib.getExe pkgs.fish}";
          layer = "overlay";
          include = "${
            inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
          }/catppuccin-latte/peach.ini";

        };
      };
    };
  };
}
