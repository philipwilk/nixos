{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.localDef.programs.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf config.localDef.programs.direnv.enable {
    xdg.config.files."direnv/direnv.toml" = {
      generator = (pkgs.formats.toml { }).generate "direnv.toml";
      value = {
        global = {
          warn_timeout = "0s";
          hide_env_diff = true;
          load_dotenv = true;
        };
      };
    };
    xdg.config.files."direnv/lib/hm-nix-direnv.sh".source =
      "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
  };
}
