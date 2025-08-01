{
  config,
  lib,
  catppuccin,
  nix-index-database,
  ...
}:
{
  imports = [
    # original modules
    ./workstation
    ./workstation/lanzaboote.nix

    # replaced modules
    # ./replace/path/to/module.nix
  ];

  options.workstation = {
    declarativeHome = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Whether to enable the use of home-manager to manage configs.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.workstation.declarativeHome {
      workstation.i18n.enable = true;
      home-manager = {
        users."philip".imports = [
          ../hmModules/home.nix
          catppuccin.homeModules.catppuccin
          nix-index-database.homeModules.nix-index
        ];
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    })
  ];
}
