{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
  home.file."${config.xdg.configHome}/nushell/nix-your-shell.nu".source =
    pkgs.nix-your-shell.generate-config "nu";
}
