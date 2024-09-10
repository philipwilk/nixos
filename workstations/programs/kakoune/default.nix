{ pkgs, config, lib, ... }:
let
  cfg = config.programs.kakoune;
in
{
  options.programs.kakoune.colorSchemePackage = lib.mkOption {
    type = lib.types.nullOr lib.types.package;
    default = null;
    example = lib.options.literalExpression "pkgs.kakounePlugins.kakoune-catppuccin";
    description = ''
      A kakoune color schemes to add to your colors folder.
      This works because kakoune recursively checks `$XDG_CONFIG_HOME/kak/colors/`.
      To apply the color scheme use `programs.kakoune.config.colorScheme = "theme"`.
    '';
  };
    
  config = lib.mkMerge [
    {
      xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;

      programs.kakoune = {
        enable = true;
        defaultEditor = true;
        config = {
          ui = {
            enableMouse = true;
            assistant = "cat";
          };
          colorScheme = "catppuccin_latte";
          showWhitespace.enable = true;
          showMatching = true;
          numberLines.enable = true;
          wrapLines.enable = true;
        };
        extraConfig = ''
          # LSP
          eval %sh{kak-lsp --kakoune -s $kak_session}
          lsp-enable

          # Kakboard
          hook global WinCreate .* %{ kakboard-enable }
        '';
        plugins = with pkgs.kakounePlugins; [
          quickscope-kak
          kakoune-vertical-selection
          kakoune-state-save
          kakboard
          kak-ansi
          fzf-kak
          byline-kak
          auto-pairs-kak
          active-window-kak
          kakoune-lsp
        ];
        colorSchemePackage = pkgs.kakounePlugins.kakoune-catppuccin;
      };
    }
    (lib.mkIf (cfg.colorSchemePackage != null) {
      xdg.configFile."kak/colors/${cfg.colorSchemePackage.name}".source =
        cfg.colorSchemePackage;
    })
  ];
}
