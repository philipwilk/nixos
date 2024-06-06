{ config, lib, ... }:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
  mkOpt = lib.mkOption;
  t = lib.types;
in
{
  imports = join-dirfile "./" [
    "master"
    "worker"
  ];

  options.homelab.buildbot = {
    enableMaster = mkOpt {
      type = t.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the buildbot master.
      '';
    };
    enableWorker = mkOpt {
      type = t.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the buildbot worker.
      '';
    };
  };

  config = {

  };
}
