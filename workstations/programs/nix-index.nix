{
  pkgs,
  ...
}:
{
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
  home.packages = with pkgs; [ comma ];
}
