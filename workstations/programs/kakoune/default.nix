{
  pkgs,
  config,
  ...
}:
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
    extraConfig  = ''
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
    colorSchemePackage = /nix/store/a9b0hmmrsicqk2rbsqgak9gwwqz430qd-kakplugin-kakoune-catppuccin-2024-03-29;
  };
}
