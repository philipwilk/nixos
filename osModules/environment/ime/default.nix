{
  pkgs,
  ...
}:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
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
}
