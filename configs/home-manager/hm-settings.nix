{ pkgs
, lib
, catppuccin
, ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.philip = {
      imports = [
        ./home.nix
        catppuccin.homeManagerModules.catppuccin
        ./programs/catppuccin.nix
      ];
    };
  };
}
