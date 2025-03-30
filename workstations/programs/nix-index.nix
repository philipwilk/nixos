{
  pkgs,
  ...
}:
{
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;
}
