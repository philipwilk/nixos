{
  lib,
  pkgs,
  config,
  ...
}:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
  mkOpt = lib.mkOption;
  t = lib.types;

  cfg = config.homelab;
in
{
  imports =
    join-dirfile "./services" [
      "nextcloud"
      "openldap/default"
      "navidrome"
      "uptime-kuma"
      "vaultwarden"
      "mediawiki"
      "nginx"
      "mail"
      "harmonia"
      "mastodon"
      "forgejo"
      "soft-serve"
      "searxng"
    ]
    ++ join-dirfile "./websites" [ "fogbox" ]
    ++ join-dirfile "./nix" [
      "hercules-ci"
      "harmonia"
    ]
    ++ join-dirfile "./games" [ "factorio" ]
    ++ [
      ./router
      ./buildbot
    ];

  options.homelab = {
    enable = mkOpt {
      type = t.bool;
      default = true;
      example = true;
      description = ''
        Enable the default homelab options:
          - ssh using key access
          - podman enabled
          - prometheus and grafana monitoring
      '';
    };
    isLeader = mkOpt {
      type = t.bool;
      default = false;
      example = true;
      description = ''
        Whether this server should act as a host for the key lab services
      '';
    };
    tld = mkOpt {
      type = t.str;
      default = null;
      example = "example.com";
      description = ''
        Default top level domain for services.
      '';
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = null;
      example = "sou.uk.regions.fogbox.uk";
      description = ''
        Fqdn hostname of the nixos install.
      '';
    };
    acme.mail = lib.mkOption {
      type = lib.types.str;
      default = null;
      example = "joe.bloggs@example.com";
      description = ''
        Email for acme cert renewals.
      '';
    };
    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib";
      example = "/mnt/state";
      description = ''
        Path to store state under
      '';
    };
    net = {
      lan = lib.mkOption {
        type = lib.types.str;
        default = "enp3s0";
        example = "eno2";
        description = ''
          Lan device to use for firewall rules
        '';
      };
      wan = lib.mkOption {
        type = lib.types.str;
        default = "enp2s0";
        example = "eno1";
        description = ''
          Wan device to use for firewall rules
        '';
      };
    };
    services = {
      grafana = {
        enable = mkOpt {
          type = t.bool;
          default = config.homelab.isLeader;
          example = false;
          description = ''
            Whether to enable the homelab grafana instance.
          '';
        };
        domain = mkOpt {
          type = t.str;
          default = "grafana.${config.homelab.tld}";
          example = "grafana.example.com";
          description = ''
            Domain for homelab grafana instance.
          '';
        };
      };
      prometheusExporters.enable = mkOpt {
        type = t.bool;
        default = true;
        example = false;
        description = ''
          Whether to enable the homelab prometheus instance.
        '';
      };
    };
  };

  config = lib.mkIf config.homelab.enable (
    lib.mkMerge [
      {
        # Assertions        
        assertions = [
          {
            assertion = config.homelab.services.openldap.enable -> config.homelab.acme.mail != null;
            message = "Openldap requires a cert for ldaps, and acme requires an email to get a cert.";
          }
          {
            assertion = config.homelab.enable -> config.homelab.tld != null;
            message = "Homelab module needs a tld for certs and nginx routing etc.";
          }
        ];
      }

      {
        environment.sessionVariables.EDITOR = "hx";

        # Accept acme terms
        security.acme = {
          acceptTerms = true;
          defaults = {
            email = config.homelab.acme.mail;
            dnsProvider = "desec";
            credentialsFile = config.age.secrets.desec.path;
          };
        };

        # Enable podman container support
        virtualisation.podman = {
          enable = true;
          dockerSocket.enable = true;
          dockerCompat = true;
        };

        # Fail2ban for ssh
        services.fail2ban = {
          enable = true;
          extraPackages = with pkgs; [ ipset ];
        };

        # Enable ssh access from only workstation ssh keys
        services.openssh = {
          enable = true;
          ports = [ 22420 ];
          listenAddresses = [
            { addr = "0.0.0.0"; }
            { addr = "[::]"; }
          ];
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };
        };
        users.users.philip.openssh.authorizedKeys.keys =
          let
            pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
            laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
            workstations = [
              pc
              laptop
            ];
          in
          workstations;

        # Power management
        powerManagement.cpuFreqGovernor = "ondemand";

        # Set passwords for my user
        age.secrets.server_password.file = ../secrets/server_password.age;
        users.users.philip = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.age.secrets.server_password.path;
        };
      }

      # Grafana
      (lib.mkIf cfg.services.grafana.enable {

        # Grafana and prometheus monithoring
        age.secrets.grafanamail.file = ../secrets/grafanamail.age;

        systemd.services.grafana.serviceConfig.LoadCredential = [
          "smtpPwd:${config.age.secrets.grafanamail.path}"
        ];

        age.secrets.prometheusBasicAuthPassword = {
          file = ../secrets/prometheus/basicAuthPassword.age;
          owner = "grafana";
        };

        services = {
          grafana = {
            enable = true;
            dataDir = "${config.homelab.stateDir}/grafana";
            provision = {
              enable = true;
              datasources.settings.datasources = [
                {
                  name = "prometheus";
                  type = "prometheus";
                  isDefault = true;
                  url = config.services.prometheus.webExternalUrl;
                  access = "proxy";
                  basicAuth = true;
                  basicAuthUser = "grafana";
                  secureJsonData.basicAuthPassword = "$__file{${config.age.secrets.prometheusBasicAuthPassword.path}}";
                }
              ];
            };
            settings = {
              server = {
                enable_gzip = true;
                enforce_domain = true;
                domain = config.homelab.services.grafana.domain;
                http_addr = "127.0.0.1";
              };
              smtp = {
                user = "grafana";
                startTLS_policy = "NoStartTLS";
                password = "$__file{/run/credentials/grafana.service/smtpPwd}";
                host = "fogbox.uk:465";
                from_address = "grafana@services.fogbox.uk";
                enabled = true;
              };
            };
          };
          # nginx to proxy grafana
          nginx.virtualHosts.${config.homelab.services.grafana.domain} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
              proxyWebsockets = true;
            };
          };
        };
      })
      (lib.mkIf cfg.services.prometheusExporters.enable {
        services.prometheus.exporters = {
          node.enable = true;
          zfs.enable = true;
        };

        age.secrets.nodeBasicAuth = {
          file = ../secrets/prometheus/exporters/node/htpasswd.age;
          owner = "nginx";
        };
        age.secrets.zfsBasicAuth = {
          file = ../secrets/prometheus/exporters/zfs/htpasswd.age;
          owner = "nginx";
        };
        services.nginx.virtualHosts = {
          "n.stats.${cfg.hostname}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.prometheus.exporters.node.port}";
              proxyWebsockets = true;
              basicAuthFile = config.age.secrets.nodeBasicAuth.path;
            };
          };
          "z.stats.${cfg.hostname}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}";
              proxyWebsockets = true;
              basicAuthFile = config.age.secrets.zfsBasicAuth.path;
            };
          };
        };
      })
      (lib.mkIf (cfg.isLeader) {
        age.secrets.nodeBasicAuthPassword = {
          file = ../secrets/prometheus/exporters/node/basicAuthPassword.age;
          owner = "prometheus";
        };
        age.secrets.zfsBasicAuthPassword = {
          file = ../secrets/prometheus/exporters/zfs/basicAuthPassword.age;
          owner = "prometheus";
        };
        services.prometheus = {
          enable = true;
          enableReload = true;
          webExternalUrl = "https://prometheus.${cfg.tld}/";
          scrapeConfigs = [
            {
              job_name = "node";
              scheme = "https";
              basic_auth = {
                username = "prometheus";
                password_file = config.age.secrets.nodeBasicAuthPassword.path;
              };
              static_configs = [
                {
                  targets = [
                    "n.stats.sou.uk.region.fogbox.uk"
                    "n.stats.rdg.uk.region.fogbox.uk"
                  ];
                }
              ];
            }
            {
              job_name = "zfs";
              scheme = "https";
              basic_auth = {
                username = "prometheus";
                password_file = config.age.secrets.zfsBasicAuthPassword.path;
              };
              static_configs = [
                {
                  targets = [
                    "z.stats.sou.uk.region.fogbox.uk"
                    "z.stats.rdg.uk.region.fogbox.uk"
                  ];
                }
              ];
            }
          ];
        };

        age.secrets.prometheusBasicAuth = {
          file = ../secrets/prometheus/htpasswd.age;
          owner = "nginx";
        };

        services.nginx.virtualHosts."prometheus.${cfg.tld}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
            proxyWebsockets = true;
            basicAuthFile = config.age.secrets.prometheusBasicAuth.path;
          };
        };
      })
      # Zfs monitoring
      (lib.mkIf config.boot.zfs.enabled {
        age.secrets.zedMailPwd.file = ../secrets/zedMailPwd.age;

        programs.msmtp = {
          enable = true;
          setSendmail = true;
          defaults = {
            aliases = "/etc/aliases";
            port = 465;
            tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
            tls = "on";
            auth = "login";
            tls_starttls = "off";
          };
          accounts = {
            default = {
              host = "${cfg.tld}";
              passwordeval = "cat ${config.age.secrets.zedMailPwd.path}";
              user = "zfs@services.${cfg.tld}";
              from = "zfs@services.${cfg.tld}";
            };
          };
        };

        services.zfs = {
          autoScrub.enable = true;
          zed = {
            settings = {
              ZED_EMAIL_ADDR = [ "philipwilk@fogbox.uk" ];
              ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
              ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

              ZED_NOTIFY_INTERVAL_SECS = 3600;
              ZED_NOTIFY_VERBOSE = false;

              ZED_USE_ENCLOSURE_LEDS = true;
              ZED_SCRUB_AFTER_RESILVER = false;
            };
            enableMail = false;
          };
        };
      })
      {
        services.mysql.dataDir = "${config.homelab.stateDir}/mysql";
        services.postgresql.dataDir = "${config.homelab.stateDir}/postgresql/${config.services.postgresql.package.psqlSchema}";
        services.postgresql.package = pkgs.postgresql_16;
      }
    ]
  );
}
