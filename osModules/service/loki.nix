{
  config,
  ...
}:
let
  lokiConfigDir = "$:{config.homelab.stateDir}/loki";
in
{
  services.loki = {
    enable = true;
    dataDir = lokiConfigDir;
    configuration = {
      auth_enabled = false;

      server.http_listen_port = 3100;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
        max_transfer_retries = 0;
      };

      schema_config = {
        configs = [
          {
            from = "2024-04-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "${lokiConfigDir}/tsdb-index";
          cache_location = "${lokiConfigDir}/tsdb-cache";
          shared_store = "filesystem";
        };

        filesystem = {
          directory = "${lokiConfigDir}/chunks";
        };
      };

      query_scheduler.max_outstanding_requests_per_tenant = 32768;

      querier.max_concurrent = 16;

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      chunk_store_config = {
        max_look_back_period = "0s";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = lokiConfigDir;
        shared_store = "filesystem";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  age.secrets.lokiHtpasswd = {
    file = ../secrets/loki/htpasswd.age;
    owner = "nginx";
  };
  services.nginx.virtualHosts."loki.stats.${config.networking.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      proxyWebsockets = true;
      basicAuthFile = config.age.secrets.lokiHtpasswd.path;
    };
  };
}
