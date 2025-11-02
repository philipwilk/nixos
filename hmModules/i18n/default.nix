{
  ...
}:
{
  home.sessionVariables = {
    "QT_QPA_PLATFORM" = "xcb";
    "QT_IM_MODULES" = "wayland;fcitx;ibus";
    "QT_IM_MODULE" = "fcitx";
    "GTK_IM_MODULE" = "fcitx";
    "SDL_IM_MODULE" = "fcitx";
    "GLFW_IM_MODULE" = "ibus";
  };

  gtk.gtk2.extraConfig = ''
    gtk-im-module="fcitx"
  '';
  gtk.gtk3.extraConfig = ''
    [Settings]
    gtk-im-module=fcitx
  '';
  gtk.gtk4.extraConfig = ''
    [Settings]
    gtk-im-module=fcitx
  '';
}
