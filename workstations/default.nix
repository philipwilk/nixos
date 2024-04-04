{ lib, pkgs, config, catppuccin, ... }:
let
  mkOpt = lib.mkOption;
  t = lib.types;
  mdDoc = lib.mkDoc;
  join-dirfile = dir: map (file: ./${dir}/${file}.nix);
in {
  imports = [ ./system.nix ./desktops/gnome ./desktops/sway ];

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

    desktop = mkOpt {
      type = t.enum [ "gnome" "sway" ];
      default = "sway";
      example = false;
      description = mdDoc ''
        Which desktop environment or window manager to enable.
      '';
    };
  };

  config = lib.mkIf config.workstation.enable {
    home-manager = lib.mkIf config.workstation.isManaged {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.philip = {
        imports = [ catppuccin.homeManagerModules.catppuccin ]
          ++ join-dirfile "programs" [
            "git"
            "nys"
            "direnv"
            "nix"
            "zoxide"
            "virtman"
            "ssh"
            "easyeffects"
            "catppuccin"
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
