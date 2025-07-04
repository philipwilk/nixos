{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "cache.${config.homelab.tld}";
  credPath = "/run/credentials/harmonia.service";
in
{
  options.homelab.nix.harmonia.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the harmonia nix cache.
    '';
  };

  config = lib.mkIf config.homelab.nix.harmonia.enable {

    age.secrets.harmonia = {
      file = ../../../secrets/harmonia.age;
      owner = "harmonia";
    };
    services.harmonia = {
      enable = true;
      signKeyPaths = [
        config.age.secrets.harmonia.path
      ];
    };

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        zstd on;
        zstd_types application/x-nix-archive;
      '';
    };
  };
}
