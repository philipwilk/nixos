{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.ci.runners.gitlab;
in
{
  options = {
    homelab.ci.runners.gitlab.csgitlab.enabled = lib.mkEnableOption "the csgitlab nix runner";
    homelab.ci.runners.gitlab.csgitlab.secretPath = lib.mkOption {
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.csgitlab.enabled {
    age.secrets.gitlab-runner-csgitlab.file = cfg.csgitlab.secretPath;

    virtualisation.docker.enable = lib.mkForce false;

    services.gitlab-runner = {
      enable = true;
      services = {
        # runner for building in docker via host's nix-daemon
        # nix store will be readable in runner, might be insecure
        nix = {
          # File should contain at least these two variables:
          # `CI_SERVER_URL`
          # `CI_SERVER_TOKEN`
          authenticationTokenConfigFile = config.age.secrets.gitlab-runner-csgitlab.path;
          dockerImage = "alpine:3";
          dockerPullPolicy = "if-not-present";
          dockerVolumes = [
            "/nix/store:/nix/store:ro"
            "/nix/var/nix/db:/nix/var/nix/db:ro"
            "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
            "/etc/nix/nix.conf:/etc/nix/nix.conf:ro"
          ];
          dockerDisableCache = true;
          preBuildScript = pkgs.writeScript "setup-container" ''
            mkdir -p -m 0755 /nix/var/log/nix/drvs
            mkdir -p -m 0755 /nix/var/nix/gcroots
            mkdir -p -m 0755 /nix/var/nix/profiles
            mkdir -p -m 0755 /nix/var/nix/temproots
            mkdir -p -m 0755 /nix/var/nix/userpool
            mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
            mkdir -p -m 1777 /nix/var/nix/profiles/per-user
            mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
            mkdir -p -m 0700 "$HOME/.nix-defexpr"

            . ${pkgs.nix}/etc/profile.d/nix.sh

            ${pkgs.nix}/bin/nix-env -i ${
              lib.concatStringsSep " " (
                with pkgs;
                [
                  nix
                  cacert
                  git
                  openssh
                ]
              )
            }

            ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
            ${pkgs.nix}/bin/nix-channel --update nixpkgs
          '';

          environmentVariables = {
            ENV = "/etc/profile";
            USER = "root";
            NIX_REMOTE = "daemon";
            PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
            NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
          };
        };
      };
    };
  };
}
