{
  lib,
  config,
  catppuccin,
  nix-index-database,
  ...
}:
{
  config = (lib.mkIf config.flakeConfig.environment.declarativeHome.enable) {
    home-manager = {
      users."philip".imports = [
        ../../../../hmModules/home.nix
        catppuccin.homeModules.catppuccin
        nix-index-database.homeModules.nix-index
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
