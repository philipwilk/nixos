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
    catppuccin.url = "github:catppuccin/nix";
    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix, nix-matlab, home-manager
    , catppuccin, auto-cpufreq, nixos-generators, lanzaboote, ... }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = fn:
        nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
      join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);

      # Regional and nix settings for all machines
      commonModules = join-dirfile "configs" [ "nix-settings" "uk-region" ];

      # Homelab
      homelabModules = commonModules
        ++ [ ./homelab agenix.nixosModules.default ];
      systemdLab = homelabModules ++ [ ./configs/boot/systemd.nix ];
      grubLab = homelabModules ++ [ ./configs/boot/grub.nix ];

      # Desktops
      workstationModules = (join-dirfile "configs/boot" [ "systemd" "lanzaboote" ])
        ++ commonModules ++ [
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          catppuccin.nixosModules.catppuccin
          lanzaboote.nixosModules.lanzaboote
          ./workstations
        ];

      buildSys = nxpkgs: mods:
        nxpkgs.lib.nixosSystem {
          modules = mods;
          specialArgs = inputs;
        };

      unstableSystem = buildSys nixpkgs-unstable;
      stableSystem = buildSys nixpkgs;

      buildIso = arch: mods: nixos-generators.nixosGenerate {
        system = arch;
        modules = [
          ./cluster
        ] ++ commonModules ++ mods;
        specialArgs = inputs;
        format = "iso";
      };
      buildX86Iso = buildIso "x86_64-linux";
    in {
      packages.x86_64-linux = {
        new-client = buildX86Iso [ ./cluster/client/new.nix ];
      };

      nixosConfigurations = {
        # Systemd machines
        nixowos = unstableSystem ([
          ./workstations/infra/nixowos
        ] ++ workstationModules);

        nixowos-laptop = unstableSystem ([
          ./workstations/infra/nixowos-laptop
          auto-cpufreq.nixosModules.default
        ] ++ workstationModules);

        mini = unstableSystem ([ 
          ./workstations/infra/mini
        ] ++ workstationModules);

        nixosvmtest= unstableSystem ([ ./homelab/infra/nixosvmtest.nix ] ++ commonModules);

        nixos-thinkcentre-tiny = unstableSystem ([ 
            ./homelab/infra/nixos-thinkcentre-tiny 
          ] ++ systemdLab);

        # Grub machines (DO NOT SUPPORT EFI BOOT)
        hp-dl380p-g8-LFF =
          stableSystem ([
            ./homelab/infra/hp-dl380p-g8-LFF
            ./homelab/services/minecraft.nix
          ] ++ grubLab);

        hp-dl380p-g8-sff-2 =
          stableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-2 ] ++ grubLab);

        hp-dl380p-g8-sff-3 =
          stableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-3 ] ++ grubLab);

        hp-dl380p-g8-sff-4 =
          stableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-4 ] ++ grubLab);

        hp-dl380p-g8-sff-5 =
          stableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-5 ] ++ grubLab);
      };
      formatter = forAllSystems (nixpkgs-unstable: nixpkgs-unstable.nixfmt);
    };
}
