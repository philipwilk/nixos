{
  pkgs,
  config,
  ...  
}:
let
  name = "atm8";
  datadir = "/data/minecraft/servers";
  slug = "all-the-mods-8";
in
{
  age.secrets.atm8.file = ../../secrets/atm8.age; 
 
  virtualisation.oci-containers.containers.${name} = {
    image = "docker.io/itzg/minecraft-server:java17-alpine";
    environment = {
      EULA = "TRUE";
      MAX_MEMORY = "16G";
      ENABLE_ROLLING_LOGS = "true";
      USE_AIKAR_FLAGS = "true";
      DIFFICULTY = "hard";
      SPAWN_PROTECTION = "0";
      ALLOW_FLIGHT = "true";
      SERVER_NAME = "${name} server";
      TYPE = "AUTO_CURSEFORGE";
      CF_SLUG = slug;
      AUTOPAUSE_KNOCK_INTERFACE = "tap0";
      ENABLE_AUTOPAUSE = "true";
      MAX_TICK_TIME = "-1";
      AUTOPAUSE_TIMEOUT_INIT = "30";
      AUTOPAUSE_TIMEOUT_EST = "30";
    };
    environmentFiles = [
      config.age.secrets.atm8.path
    ];
    extraOptions = [
      "--cap-add=CAP_NET_RAW"
      "--network=slirp4netns:port_handler=slirp4netns"
    ];
    ports = [ "25565:25565" ];
    volumes = [ "${datadir}/${name}:/data:Z" ];
  };
}
