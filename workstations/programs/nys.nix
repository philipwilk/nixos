{
  config,
  pkgs,
  ...
}:
{
  programs.carapace.enable = true;
  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };
}
