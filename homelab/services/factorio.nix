{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.homelab.services.factorio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the factorio game server.
      '';
    };
    admins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "username" ];
      description = ''
        List of game admins that can run commands/pause etc.
      '';
    };
  };
  
  config = lib.mkIf config.homelab.services.factorio.enable {
    age.secrets.factorio_password.file = ../../secrets/factorio_password.age;
    services.factorio = {
      enable = true;
      package = pkgs.factorio-headless;
      openFirewall = true;
      requireUserVerification = true;
      game-name = "broken bad";
      admins = config.homelab.services.factorio.admins;
      loadLatestSave = true;
      lan = true;
      nonBlockingSaving = true;
      autosave-interval = 5;
    };
  };
}
