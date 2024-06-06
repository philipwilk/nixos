{ pkgs, config, ... }:
let
  name = "atm8";
  datadir = "/data/minecraft/servers";
  slug = "all-the-mods-8";
  user = "podman";
  port = 10565;
in
{
  age.secrets.atm8 = {
    file = ../../secrets/atm8.age;
    owner = user;
    group = user;
  };

  users.users.${user} = {
    isSystemUser = true;
    group = user;
  };
  users.groups.${user} = { };

  networking.firewall.allowedTCPPorts = [ port ];

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
      ENABLE_WHITELIST = "true";
      EXISTING_WHITELIST_FILE = "MERGE";
      WHITELIST = "wiryfuture";
      EXISTING_OPS_FILE = "MERGE";
      OPS = "wiryfuture";
      CF_SLUG = slug;
      AUTOPAUSE_KNOCK_INTERFACE = "tap0";
      ENABLE_AUTOPAUSE = "true";
      MAX_TICK_TIME = "-1";
      AUTOPAUSE_TIMEOUT_INIT = "30";
      AUTOPAUSE_TIMEOUT_EST = "30";
      UID = user;
      GID = user;
      SYNC_CHUNK_WRITES = "false";
      MODS = ''
        https://mediafilez.forgecdn.net/files/5216/876/Chunk-Pregenerator-1.19.2-4.4.3.jar
      '';
    };
    environmentFiles = [ config.age.secrets.atm8.path ];
    extraOptions = [
      "--cap-add=CAP_NET_RAW"
      "--network=slirp4netns:port_handler=slirp4netns"
    ];
    ports = [ "${toString port}:25565" ];
    volumes = [ "${datadir}/${name}:/data:Z" ];
  };
}
