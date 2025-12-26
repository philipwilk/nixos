{
  lib,
  config,
  ...
}:
{

  options.localDef.programs.fcitx.enable = lib.mkEnableOption "fcitx";

  config = lib.mkIf config.localDef.programs.fcitx.enable {
    environment.sessionVariables = {
      "QT_QPA_PLATFORM" = "xcb";
      "QT_IM_MODULES" = "wayland;fcitx;ibus";
      "QT_IM_MODULE" = "fcitx";
      "GTK_IM_MODULE" = "fcitx";
      "SDL_IM_MODULE" = "fcitx";
      "GLFW_IM_MODULE" = "ibus";
    };
  };
}
