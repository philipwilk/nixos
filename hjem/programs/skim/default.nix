{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.localDef.programs.skim.enable = lib.mkEnableOption "skim";

  config = lib.mkIf config.localDef.programs.skim.enable {
    packages = with pkgs; [ skim ];

    localDef.programs.fish.interactiveInit = "source ${pkgs.skim}/share/skim/key-bindings.fish && skim_key_bindings";
  };
}
