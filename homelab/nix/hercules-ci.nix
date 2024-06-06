{ config, lib, ... }:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
  mkOpt = lib.mkOption;
  t = lib.types;
in
{
  options.homelab.nix.hercules-ci.enable = mkOpt {
    type = t.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the hercules-ci agent.
    '';
  };

  config = lib.mkIf config.homelab.nix.hercules-ci.enable {
    age.secrets = {
      binaryCacheKeys = {
        file = ../../secrets/hercules-ci/binaryCacheKeys.age;
        owner = "hercules-ci-agent";
        group = "hercules-ci-agent";
      };
      clusterJoinToken = {
        file = ../../secrets/hercules-ci/clusterJoinToken.age;
        owner = "hercules-ci-agent";
        group = "hercules-ci-agent";
      };
      secretsJson = {
        file = ../../secrets/hercules-ci/secretsJson.age;
        owner = "hercules-ci-agent";
        group = "hercules-ci-agent";
      };
    };

    services.hercules-ci-agent = {
      enable = true;
      settings = {
        binaryCachesPath = config.age.secrets.binaryCacheKeys.path;
        clusterJoinTokenPath = config.age.secrets.clusterJoinToken.path;
        secretsJsonPath = config.age.secrets.secretsJson.path;
      };
    };
  };
}
