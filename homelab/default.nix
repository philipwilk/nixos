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
in
{
  imports =
    join-dirfile "./services" [
      "nextcloud"
      "openldap/default"
      "factorio"
      "navidrome"
      "uptime-kuma"
      "vaultwarden"
      "mediawiki"
      "sshBastion"
      "nginx"
      "mail"
      "harmonia"
    ]
    ++ join-dirfile "./websites" [ "fogbox" ]
    ++ join-dirfile "./nix" [ "hercules-ci" ]
    ++ [
      ./router
      ./buildbot
    ];

  options.homelab = {
    enable = mkOpt {
      type = t.bool;
      default = false;
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
    acme.mail = mkOpt {
      type = t.str;
      default = null;
      example = "joe.bloggs@example.com";
      description = ''
        Email for acme cert renewals.
      '';
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
      prometheus.enable = mkOpt {
        type = t.bool;
        default = config.homelab.isLeader;
        example = false;
        description = ''
          Whether to enable the homelab prometheus instance.
        '';
      };
    };
  };

  config = lib.mkIf config.homelab.enable {
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
    age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
    age.secrets.server_password.file = ../secrets/server_password.age;
    users.users.philip = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      hashedPasswordFile = config.age.secrets.server_password.path;
    };

    #  Networking
    networking.networkmanager.enable = true;

    # Allow grafana in/out
    networking.firewall.interfaces."eno1".allowedTCPPorts = [ config.services.prometheus.port ];

    # Grafana and prometheus monithoring
    age.secrets.grafanamail.file = ../secrets/grafanamail.age;

    systemd.services.grafana.serviceConfig.LoadCredential = [
      "smtpPwd:${config.age.secrets.grafanamail.path}"
    ];
    
    services = {
      grafana = {
        enable = config.homelab.services.grafana.enable;
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "prometheus";
              type = "prometheus";
              url = "http://localhost:${toString config.services.prometheus.port}";
              access = "proxy";
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
      prometheus = {
        enable = config.homelab.services.prometheus.enable;
        enableReload = true;
        webExternalUrl = "http://192.168.1.10:${toString config.services.prometheus.port}/";
        scrapeConfigs = lib.mkIf config.homelab.isLeader [
          {
            job_name = "node";
            static_configs = [
              {
                targets =
                  let
                    p = toString config.services.prometheus.exporters.node.port;
                  in
                  [
                    "localhost:${p}"
                    "192.168.2.1:${p}"
                    "192.168.2.2:${p}"
                    "192.168.2.3:${p}"
                    "192.168.2.4:${p}"
                    "192.168.2.5:${p}"
                  ];
              }
            ];
          }
          {
            job_name = "haproxy";
            scrape_interval = "30s";
            scrape_timeout = "20s";
            static_configs = [ { targets = [ "192.168.1.0:8404" ]; } ];
          }
          {
            job_name = "endlessh-go";
            scrape_interval = "30s";
            scrape_timeout = "20s";
            static_configs = [
              { targets = [ "192.168.1.10:${toString config.services.endlessh-go.prometheus.port}" ]; }
            ];
          }
        ];
        exporters = {
          node = {
            enable = true;
            openFirewall = true;
          };
        };
      };
    };
  };
}
