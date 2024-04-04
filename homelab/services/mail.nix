{ config, lib, ... }: {
  config = lib.mkIf config.homelab.services.email.enable { };
}
