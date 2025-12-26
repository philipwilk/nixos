{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.localDef.programs.nix-index.enable = lib.mkEnableOption "nix-index";

  config = lib.mkIf config.localDef.programs.nix-index.enable {
    packages = with pkgs; [
      nix-index
    ];

    localDef.programs.fish.interactiveInit =
      let
        wrapper = pkgs.writeScript "command-not-found" ''
          #!${pkgs.bash}/bin/bash
          source ${lib.getExe pkgs.nix-index}/etc/profile.d/command-not-found.sh
          command_not_found_handle "$@"
        '';
      in
      ''
        function __fish_command_not_found_handler --on-event fish_command_not_found
            ${wrapper} $argv
        end
      '';
  };
}
