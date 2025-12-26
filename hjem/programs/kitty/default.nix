{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.localDef.programs.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.localDef.programs.kitty.enable {
    packages = with pkgs; [ kitty ];

    xdg.config.files."kitty/kitty.conf".text = ''
      include ${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Latte.conf

      shell_integration no-rc

      confirm_os_window_close 0
    '';

    localDef.programs.fish.interactiveInit = ''
      if set -q KITTY_INSTALLATION_DIR
        set --global KITTY_SHELL_INTEGRATION no-rc
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
      end
    '';
  };
}
