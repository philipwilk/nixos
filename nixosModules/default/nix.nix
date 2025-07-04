{
  nixpkgs,
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixVersions.latest.overrideAttrs {
      patches = [
        ../../overlays/nix/0001-Gracefully-fallback-from-failing-substituters.patch
      ];
    };
    registry = lib.mapAttrs (_: value: { flake = value; }) {
      inherit nixpkgs;
    };
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes auto-allocate-uids ca-derivations";
      auto-optimise-store = true;
      trusted-users = [ "philip" ];
      substituters = [ "https://cache.fogbox.uk" ];
      trusted-public-keys = [ "cache.fogbox.uk:lwlsX4TZdJXQzfqTWRMf/I8xTlR/i+B5RTkD2BQhzdA=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d --delete-older-than 14d";
      persistent = true;
    };
  };
}
