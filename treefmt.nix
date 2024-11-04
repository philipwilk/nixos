# treefmt.nix
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
  };

  settings.global.excludes = [
    "*.age"
    "*.ldif"
    "*.envrc"
    "*.css"
  ];
}
