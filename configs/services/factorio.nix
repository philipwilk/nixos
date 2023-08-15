{ config, ... }: {
  age.secrets.factorio_password.file = ../../secrets/factorio_password.age;
  services.factorio = {
    enable = true;
    openFirewall = true;
    requireUserVerification = true;
    game-name = "broken bad";
    admins = [ "wiryfuture" ];
    loadLatestSave = true;
    lan = true;
    nonBlockingSaving = true;
    autosave-interval = 5;
  };
}
