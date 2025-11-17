{
  pkgs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      corefonts
      noto-fonts-emoji-blob-bin
      noto-fonts-color-emoji
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      fira-code
      fira-code-symbols
      material-design-icons
    ];
    fontDir.enable = true;
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK"
        ];
        emoji = [
          "Blobmoji"
          "Noto Color Emoji"
          "Material Design Icons"
        ];
        monospace = [ "Fira Code" ];
      };
    };
  };
}
