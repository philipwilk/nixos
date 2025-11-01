{ config, lib, ... }:
{
  config = lib.mkIf config.homelab.buildbot.enableWorker {
    age.secrets.worker_sec.file = ../../../secrets/buildbot/worker_sec.age;

    services.buildbot-nix.worker = {
      enable = true;
      workerPasswordFile = config.age.secrets.worker_sec.path;
    };
  };
}
