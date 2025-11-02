{
  lib,
  config,
  catppuccin,
  nix-index-database,
  ...
}:
let
  user = config.flakeConfig.environment.primaryHomeManagedUser;
in
{
  config = lib.mkIf (user != null) {
    home-manager = {
      users.${user}.imports = [
        ../../../../hmModules
        ../../../../hmModules/users/${user}
        catppuccin.homeModules.catppuccin
        nix-index-database.homeModules.nix-index
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
