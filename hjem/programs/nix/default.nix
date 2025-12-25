{
  lib,
  config,
  ...
}:
{
  options.localDef.programs.nix.enable = lib.mkEnableOption "nix";

  config = lib.mkIf config.localDef.programs.nix.enable {
    xdg.config.files."nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
      }
    '';
  };
}
