{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    buildbot-nix = {
      url = "github:Mic92/buildbot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      system = "x86_64-linux";
      systems = [ system ];
      forAllSystems =
        fn: inputs.nixpkgs.lib.genAttrs systems (sys: fn inputs.nixpkgs.legacyPackages.${sys});
      join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);

      treefmtEval = forAllSystems (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      # Regional and nix settings for all machines
      commonModules = join-dirfile "configs" [
        "nix-settings"
        "uk-region"
      ];

      # Homelab
      homelabSys = commonModules ++ [
        ./homelab
        inputs.agenix.nixosModules.default
        ./homelab/config.nix
        inputs.buildbot-nix.nixosModules.buildbot-master
        inputs.buildbot-nix.nixosModules.buildbot-worker
        ./configs/boot/systemd.nix
      ];

      # Desktops
      workstationModules =
        (join-dirfile "configs/boot" [
          "systemd"
          "lanzaboote"
        ])
        ++ commonModules
        ++ [
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          inputs.catppuccin.nixosModules.catppuccin
          inputs.lanzaboote.nixosModules.lanzaboote
          ./workstations
        ];

      buildIso =
        arch: mods:
        inputs.nixos-generators.nixosGenerate {
          system = arch;
          modules = [ ./cluster ] ++ commonModules ++ mods;
          specialArgs = inputs;
          format = "iso";
        };
      buildX86Iso = buildIso system;

      patches = [
        {
          meta.description = "rustdesk-flutter: fix build #356450";
          url = "https://github.com/NixOS/nixpkgs/pull/356450/commits/b932f695ed895e02c8687a2bafaa215332bcae30.patch";
          sha256 = "2NIivzZ7/EKnyCJwNApoKbBMnvUwa2GBQB1GwJW8msY=";
        }
        {
          meta.description = "python312Packages.pyside6: fix eval on linux #356081";
          url = "https://github.com/NixOS/nixpkgs/pull/356081.patch";
          sha256 = "6PhvfzyRXNlMlgVawBx29yLKDUsoOljWKJs7ryEzCFM=";
        }
      ];

      pkgs = inputs.nixpkgs.legacyPackages.${system};
      nixpkgs = pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = inputs.nixpkgs;
        patches = map pkgs.fetchpatch patches;
      };
      nixosSystem = import (nixpkgs + "/nixos/lib/eval-config.nix");
      buildSystem =
        modules:
        nixosSystem {
          inherit modules;
          inherit system;
          specialArgs = inputs;
        };
    in
    {
      # packages.x86_64-linux = {
      # new-client = buildX86Iso [ ./cluster/client/new.nix ];
      # };

      nixosConfigurations = {
        # Systemd machines
        prime = buildSystem ([ ./workstations/infra/prime ] ++ workstationModules);

        probook = buildSystem ([ ./workstations/infra/probook ] ++ workstationModules);

        mini = buildSystem ([ ./workstations/infra/mini ] ++ workstationModules);

        # nixosvmtest = unstableSystem ([ ./homelab/infra/nixosvmtest.nix ] ++ commonModules);

        thinkcentre = buildSystem ([ ./homelab/infra/thinkcentre ] ++ homelabSys);
        itxserve = buildSystem ([ ./homelab/infra/itxserve ] ++ homelabSys);
      };

      formatter = forAllSystems (nixpkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = forAllSystems (
        pkgs:
        let
          lib = inputs.nixpkgs.lib;
          inherit (pkgs.stdenv.hostPlatform) system;
        in
        lib.mergeAttrsList [
          {
            formatting = treefmtEval.${system}.config.build.check self;
          }

          # devShells.x86_64-linux.default -> devShells-default
          (lib.mapAttrs' (name: lib.nameValuePair "devShells-${name}") self.devShells.${system})

          # nixosConfigurations.machine -> nixosConfigurations-machine
          # (and also makes sure they are for the current system)
          (lib.filterAttrs (lib.const (deriv: deriv.system == system)) (
            lib.mapAttrs' (
              name: value: lib.nameValuePair "nixosConfigurations-${name}" value.config.system.build.toplevel
            ) self.nixosConfigurations
          ))
        ]
      );

      devShells."x86_64-linux".default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nix-tree
        ];
      };
    };
}
