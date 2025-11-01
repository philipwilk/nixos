{
  pkgs,
  lib,
  ...
}:
let
  mkEnabledOption =
    name:
    lib.mkOption {
      default = true;
      example = false;
      description = "Whether to enable ${name}.";
      type = lib.types.bool;
    };
in
{
  imports = [
    # replaced modules
    # ./replaced/path/to/module.nix

    # Desktop environments
    ./environment/desktops/gnome
    ./environment/desktops/sway

    ./system/latestKernel
    ./system/bootable
    ./system/region

    ./environment/programs/fish
    ./environment/programs/nix
    ./environment/programs/agenix

    ./environment/baseCli
  ];

  options.flakeConfig = {
    environment = {
      desktop = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "gnome"
            "sway"
          ]
        );
        default = null;
        example = "gnome";
        description = ''
          Which desktop environment or window manager to enable.
        '';
      };

      declarativeHome.enable = lib.mkEnableOption "home-manager to manage configs.";
    };

    system.bootable.enable = mkEnabledOption "systemd-boot and firmware configs";
  };

  config = {
    networking.nftables.enable = lib.mkDefault true;
    environment.sessionVariables.NH_FLAKE = lib.mkDefault "/home/philip/repos/nixos";
  };
}
