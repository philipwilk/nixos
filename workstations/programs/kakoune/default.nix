{
  pkgs,
  config,
  lib,
  ...
}:
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
      programs.kakoune = {
        enable = true;
        defaultEditor = true;
        config = {
          ui = {
            enableMouse = true;
            assistant = "cat";
          };
          tabStop = 2;
          indentWidth = 2;
          colorScheme = "catppuccin_latte";
          showWhitespace.enable = true;
          showMatching = true;
          numberLines.enable = true;
          wrapLines.enable = true;
        };
        extraConfig = ''
          # Enable auto pairs
          enable-auto-pairs

          # Smarttab
          hook global BufOpenFile .* expandtab
          hook global BufNewFile  .* expandtab

          hook global BufCreate .* %{
            editorconfig-load
            autoconfigtab
          }

          hook global ModuleLoaded smarttab %{
            set-option global softtabstop ${toString config.programs.kakoune.config.tabStop}
          }

          # LSP
          eval %sh{kak-lsp --kakoune -s $kak_session}
          lsp-enable

          # # LSP servers
          hook -group lsp-filetype-nix global BufSetOption filetype=nix %{
            set-option buffer lsp_servers %{
              [nil.settings]
              "formatting.command" = "nix fmt"
            }
          }

          hook -group lsp-filetype-java global BufSetOption filetype=java %{
            set-option buffer lsp_servers %{
              [java-language-server]
              root_globs = ["mvnw", "gradlew", ".git", ".hg"]
              command = "java-language-server"
            }
          }

          # # Format file on write
          hook global BufSetOption filetype=* %{
            hook buffer BufWritePre .* lsp-formatting-sync
          }

          lsp-inlay-hints-enable global

          # Bind lsp tab completion and tab indenting
          map global insert <tab> <c-n>
          map global insert <s-tab> <c-p>

          hook global InsertCompletionShow .* %{
            map global insert <tab> <c-n>
            map global insert <s-tab> <c-p>
          }
          hook global InsertCompletionHide .* %{
            unmap global insert <tab>
            unmap global insert <s-tab>
          }

          map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"

          map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'

          map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
          map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
          map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
          map global object t '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
          map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
          map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

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
          smarttab-kak
        ];
        colorSchemePackage = pkgs.kakounePlugins.kakoune-catppuccin;
      };
    }
    (lib.mkIf (cfg.colorSchemePackage != null) {
      xdg.configFile."kak/colors/${cfg.colorSchemePackage.name}".source = cfg.colorSchemePackage;
    })
  ];
}
