{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.workstations.i18n;
in
{
  options = {
    workstations.i18n.enable = lib.mkEnableOption "IMF/IME input methods";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        plasma6Support = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-rime
          fcitx5-hangul
        ];
        settings = {
          addons = {
            pinyin.globalSection.EmojiEnabled = "True";
          };
        };
      };
    };

    home-manager.users.philip = {
      home.sessionVariables = {
        "QT_QPA_PLATFORM" = "xcb";
        "QT_IM_MODULES" = "wayland;fcitx;ibus";
        "QT_IM_MODULE" = "fcitx";
        "XMODIFIERS " = "@im=fcitx";
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
    };
  };
}
