{
  lib,
  config,
  inputs,
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
        inputs.catppuccin.homeModules.catppuccin
        inputs.nix-index-database.homeModules.nix-index
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
