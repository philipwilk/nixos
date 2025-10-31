{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homelab.games.factorio;
  package = pkgs.factorio-headless; # .override { versionsJson = ./factorio.json; };
in
{
  options.homelab.games.factorio = {
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

  config = lib.mkIf cfg.enable {
    age.secrets.factorio_password.file = ../../../secrets/factorio_password.age;
    services.factorio = {
      enable = true;
      inherit package;
      openFirewall = true;
      requireUserVerification = true;
      game-name = "space trains";
      admins = cfg.admins;
      loadLatestSave = true;
      lan = true;
      nonBlockingSaving = true;
      autosave-interval = 5;
      extraSettingsFile = config.age.secrets.factorio_password.path;
    };

    networking.domains.subDomains."factorio.game.${config.homelab.tld}" = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
