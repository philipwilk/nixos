{
  config,
  pkgs,
  lib,
  ...
}:
{
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
