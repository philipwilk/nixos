{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.homelab.services.nextcloud.enable {
    age.secrets.nextcloud_admin = {
      file = ../../secrets/nextcloud_admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    age.secrets.nextcloud_sql = {
      file = ../../secrets/nextcloud_sql.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    # Enable nextcloud
    services.nextcloud = {
      enable = true;
      https = true;
      nginx.recommendedHttpHeaders = true;
      autoUpdateApps.enable = true;
      maxUploadSize = "4096M";
      enableImagemagick = true;
      hostName = config.homelab.services.nextcloud.domain;
      config = {
        extraTrustedDomains = [ "192.168.1.10" ];
        adminpassFile = config.age.secrets.nextcloud_admin.path;
        adminuser = "philip";
        trustedProxies = [ "192.168.1.0" ];
        dbtype = "mysql";
        dbhost = "localhost";
        dbname = "nextcloud";
        dbpassFile = config.age.secrets.nextcloud_sql.path;
      };
      extraOptions = { mysql = { utf8mb4 = true; }; };
      package = pkgs.nextcloud29;
    };

    services.mysql = {
      enable = true;
      package = pkgs.mariadb_1011;
      settings = {
        msqld = {
          max_allowed_packet = "64M";
          connect_timeout = 30;
          net_buffer_length = "64M";
          innodb_file_per_table = "ON";
          character_set_server = "utf8mb4";
          collation_server = "utf8mb4_general_ci";
        };
        client = { "default-character-set" = "utf8mb4"; };
      };
    };

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "~ \\.(?:css|js|mjs|svg|gif|png|jpg|jpeg|ico|wasm|tflite|map|html|ttf|bcmap|mp4|webm|ogg|flac)$".extraConfig = lib.mkForce ''
          try_files $uri /index.php$request_uri;
          access_log off;
          location ~ \.mjs$ {
            default_type text/javascript;
          }
          location ~ \.wasm$ {
            default_type application/wasm;
          }
        '';
        "~ \.woff2?$".extraConfig = ''
          try_files $uri /index.php$request_uri;
          expires 7d;
          access_log off;
        '';
      };
    };

    # ensure that mariadb is running *before* running the setup
    systemd.services."nextcloud-setup" = {
      requires = [ "mysql.service" ];
      after = [ "mysql.service" ];
    };
  };
}
