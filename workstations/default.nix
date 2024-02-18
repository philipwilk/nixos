{ lib
, pkgs
, config
, catppuccin
, ...
}:
let
  mkOpt = lib.mkOption;
  t = lib.types;
  mdDoc = lib.mkDoc;
  join-dirfile = dir: map (file: ./${dir}/${file}.nix);
in
{
  imports = [
    ./system.nix
  ];

  options.workstation = {
    enable = mkOpt {
      type = t.bool;
      default = true;
      example = false;
      description = mdDoc ''
        Whether to enable the workstation app suite.
      '';
    };
    isManaged = mkOpt {
      type = t.bool;
      default = true;
      example = false;
      description = mdDoc ''
        Whether to enable the use of home-manager to manage configs.
      '';
    };

    desktop = {
      sway.enable = mkOpt {
        type = t.bool;
        default = true;
        example = false;
        description = mdDoc ''
          Whether to enable the sway window manager.
        '';
      };
      gnome.enable = mkOpt {
        type = t.bool;
        default = false;
        example = true;
        description = mdDoc ''
          Whether to enable the gnome desktop environment.
        '';
      };
    };
  };

  config = lib.mkIf config.workstation.enable {
    # Assertions        
    assertions =
      let
        dsktp = config.workstation.desktop;
      in
      [
        {
          assertion = dsktp.sway.enable -> dsktp.gnome.enable != true;
          message = "Sway and gnome cannot be enabled simultaneously.";
        }
      ];

    home-manager = lib.mkIf config.workstation.isManaged {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.philip = {
        imports = [
          catppuccin.homeManagerModules.catppuccin
        ] ++
        join-dirfile "programs" [
          "git"
          "nys"
          "nix"
          "zoxide"
          "virtman"
          "ssh"
          "easyeffects"
          "catppuccin"
        ] ++ [
          ./desktops/sway
        ];

        home = {
          username = "philip";
          homeDirectory = "/home/philip";
          stateVersion = "24.05";
        };
        programs.home-manager.enable = true;
      };
    };
  };
}
