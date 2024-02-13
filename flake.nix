{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin.url = "github:Stonks3141/ctp-nix";
    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , agenix
    , nix-matlab
    , home-manager
    , catppuccin
    , ...
    } @ inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});    
      join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);

      # Regional and nix settings for all machines
      commonModules = join-dirfile "configs" [
        "nix-settings"
        "uk-region"
      ];

      # Homelab
      homelabModules = commonModules ++ [ ./homelab agenix.nixosModules.default ];
      systemdLab = homelabModules ++ [ ./configs/boot/systemd.nix ];
      grubLab = homelabModules ++ [ ./configs/boot/grub.nix ];

      # Desktops
      workstationModules = (join-dirfile "configs" [
        "boot/systemd"
        "kb"
        "workstation"
        "home-manager/hm-settings"
      ]) ++ commonModules ++ [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        catppuccin.nixosModules.catppuccin
      ];
    in
    {
      nixosConfigurations = {
        # Systemd machines
        nixowos = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./configs/machines/nixowos/configuration.nix ] ++ workstationModules;
        };
        nixowos-laptop = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./configs/machines/nixowos-laptop/configuration.nix ] ++ workstationModules;
        };
        mini = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./configs/machines/mini/configuration.nix ./configs/boot/systemd.nix ] ++ commonModules;
        };
        nixos-thinkcentre-tiny = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/nixos-thinkcentre-tiny/configuration.nix ] ++ systemdLab;
        };

        # Grub machines (DO NOT SUPPORT EFI BOOT)
        hp-dl380p-g8-LFF = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/hp-dl380p-g8-LFF/configuration.nix ] ++ grubLab;
          };
        hp-dl380p-g8-sff-2 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/hp-dl380p-g8-sff-2/configuration.nix ] ++ grubLab;
        };
        hp-dl380p-g8-sff-3 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/hp-dl380p-g8-sff-3/configuration.nix ] ++ grubLab;
        };
        hp-dl380p-g8-sff-4 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/hp-dl380p-g8-sff-4/configuration.nix ] ++ grubLab;
        };
        hp-dl380p-g8-sff-5 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./homelab/infra/hp-dl380p-g8-sff-5/configuration.nix ] ++ grubLab;
        };
      };
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
