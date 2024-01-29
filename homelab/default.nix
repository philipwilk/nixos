{ lib
, pkgs
, config
, ...
}:
{
  options.homelab =
    let
      join-dirfiles = builtins.map (folder: file: ./${folder}/${file}.nix);
    in
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = lib.mdDoc ''
          Enable the default homelab options:
            - ssh using key access
            - podman enabled
            - prometheus and grafana monitoring
        '';
      };
      isLeader = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = lib.mdDoc ''
          Whether this server should act as a host for the key lab services
        '';
      };
    };

  config =
    let
      domain = "fogbox.uk";
    in
    lib.mkIf config.homelab.enable
      {
        # Enable podman container support
        virtualisation.podman = {
          enable = true;
          dockerSocket.enable = true;
          dockerCompat = true;
          enableNvidia = true;
        };

        # Enable ssh access from only workstation ssh keys
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };
        };
        users.users.philip.openssh.authorizedKeys.keys =
          let
            pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
            pc-2fac = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILzOvLWJmyZdEKTg/LqKbIpQaukWof26OT29Qi7M8h1gAAAABHNzaDo= pc key";
            laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
            workstations = [ pc pc-2fac laptop ];
          in
          workstations;

        # Power management
        powerManagement.cpuFreqGovernor = "ondemand";

        # Set passwords for my user
        age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
        age.secrets.server_password.file = ../secrets/server_password.age;
        users.users.philip = {
          isNormalUser = true;
          extraGroups = [ "networkmanager" "wheel" ];
          hashedPasswordFile = config.age.secrets.server_password.path;
        };

        #  Networking
        networking.networkmanager.enable = true;

        # Allow grafana in/out
        networking.firewall.interfaces."eno1".allowedTCPPorts = [
          config.services.grafana.settings.server.http_port
          config.services.prometheus.port
        ];

        # Grafana and prometheus monithoring
        services = {
          grafana = lib.mkIf config.homelab.isLeader {
            enable = true;
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
                domain = "grafana.${domain}";
                http_addr = "0.0.0.0";
              };
            };
          };
          prometheus = {
            enable = config.homelab.isLeader;
            enableReload = true;
            webExternalUrl = "http://192.168.1.10:${toString config.services.prometheus.port}/";
            scrapeConfigs = lib.mkIf config.homelab.isLeader [
              {
                job_name = "node";
                static_configs = [{
                  targets = 
                  let 
                    p = toString config.services.prometheus.exporters.node.port;
                  in [
                    "localhost:${p}"
                    "192.168.2.1:${p}"
                    "192.168.2.2:${p}"
                    "192.168.2.3:${p}"
                    "192.168.2.4:${p}"
                    "192.168.2.5:${p}"
                  ];
                }];
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
