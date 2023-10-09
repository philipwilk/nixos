{ pkgs
, lib
, ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.philip = { imports = [ ./home.nix ]; };
  };
}
