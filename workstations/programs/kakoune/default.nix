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
  config = {
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
        colorScheme = "solarized-light";
        showWhitespace.enable = true;
        showMatching = true;
        numberLines.enable = true;
        wrapLines.enable = true;
      };
      extraConfig = ''
        # Enable auto folder creation (why is this not a default)
        hook global BufWritePre .* %{ nop %sh{ mkdir -p $(dirname "$kak_hook_param") }}

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

        lsp-auto-hover-disable
        lsp-inlay-hints-enable global

        # # LSP servers
        hook -group lsp-filetype-nix global BufSetOption filetype=nix %{
          set-option buffer lsp_servers %{
            [nil]
            root_globs = ["flake.nix", "shell.nix", ".git", ".hg"]
            [nil.settings]
            nil.formatting.command = ["nixfmt"]
          }
        }

        hook -group lsp-filetype-java global BufSetOption filetype=java %{
          set-option buffer lsp_servers %{
            [jdtls]
            root_globs = ["mvnw", "gradlew", ".git", ".hg"]
            [jdtls.settings]
            "java.format.insertSpaces" = true
            "java.format.tabChar" = "space"
            "java.format.tabSize" = 2
            "java.format.insertSpaceAfterClosingAngleBracketInTypeArguments" = "insert"
            "java.format.insertSpaceAfterOpeningAngleBracketInTypeArguments" = "insert"
            "java.format.insertSpaceAfterClosingAngleBracketInParameterizedTypeReference" = "insert"
            "java.format.insertSpaceAfterOpeningAngleBracketInParameterizedTypeReference" = "insert"
            "java.format.insertSpaceAfterOpeningBraceInArrayInitializer" = "insert"
            "java.format.insertSpaceBeforeClosingBraceInArrayInitializer" = "insert"
            "java.format.insertSpaceBetweenEmptyBracketsInArrayAllocationExpression" = "insert"
          }
         }

        hook -group lsp-filetype-csharp global BufSetOption filetype=csharp %{
          set-option buffer lsp_servers %{
            [csharp-ls]
            root_globs = ["cs", "csproj"]
            command = "csharp-ls"
          }
        }

        hook -group lsp-filetype-xml global BufSetOption filetype=xml %{
          set-option buffer lsp_servers %{
            [lemminx]
            root_globs = ["xml", "html", "fxml"]
            command = "lemminx"
          }
        }

        # # Format file on write
        hook global WinCreate .* %{
          hook buffer BufWritePre .* lsp-formatting-sync
        }

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
      #colorSchemePackage = pkgs.kakounePlugins.kakoune-catppuccin;
    };
  };
}
