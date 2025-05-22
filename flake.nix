{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    make-shell.url = "github:nicknovitski/make-shell";
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
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        self,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.make-shell.flakeModules.default
        ];

        systems = [
          "x86_64-linux"
        ];

        flake =
          {
            lib,
            ...
          }:
          {
            nixosConfigurations = withSystem "x86_64-linux" (
              { pkgs, ... }:
              let
                join-dirfile-gen =
                  ext: dir: files:
                  (map (file: ./${dir}/${file}${ext}) files);
                join-dirfile = join-dirfile-gen ".nix";
                join-dirpatch = join-dirfile-gen ".patch";

                # Regional and nix settings for all machines
                commonModules =
                  (join-dirfile "configs" [
                    "nix-settings"
                    "uk-region"
                  ])
                  ++ [
                    ./homelab/networking/wireguard.nix
                  ];

                # Homelab
                homelabSys =
                  commonModules
                  ++ [
                    ./homelab
                    inputs.agenix.nixosModules.default
                    ./homelab/config.nix
                    inputs.buildbot-nix.nixosModules.buildbot-master
                    inputs.buildbot-nix.nixosModules.buildbot-worker
                  ]
                  ++ (join-dirfile "configs/" [
                    "boot/systemd"
                    "idmUserAuth"
                    "zfs"
                  ]);

                # Desktops
                workstationModules =
                  (join-dirfile "configs/boot" [
                    "systemd"
                    "lanzaboote"
                  ])
                  ++ commonModules
                  ++ [
                    hm
                    inputs.agenix.nixosModules.default
                    inputs.catppuccin.nixosModules.catppuccin
                    inputs.nix-index-database.nixosModules.nix-index
                    inputs.lanzaboote.nixosModules.lanzaboote
                    ./workstations
                    ./workstations/iwd.nix
                  ];

                remotePatches = map pkgs.fetchpatch [
                  # {
                  #   meta.description = "description for the patch" ;
                  #   url = "";
                  #   hash = "";
                  # }
                ];

                localPatches = join-dirpatch "patches" [
                  "nut"
                  "0001-nut-add-override-for-apc_modbus-feature"
                  "0002-nixos-ups-add-package-option"
                  # mlxtend patchset
                  "0001-python3Packages.mlxtend-0.23.3-0.23.4"
                  "0003-python3Packages.mlxtend-fix-scikit-1.6.0-compat"
                  "0004-python3Packages.mlxtend-disable-failing-tests-test_e"
                  "0001-linux-firmware-pin-to-6.14.5-version"
                ];

                hmPatches = [
                ];

                nixpkgs = pkgs.applyPatches {
                  name = "nixpkgs-patched";
                  src = inputs.nixpkgs;
                  patches = remotePatches ++ localPatches;
                };
                nixosSystem = import (nixpkgs + "/nixos/lib/eval-config.nix");
                buildSystem =
                  modules:
                  nixosSystem {
                    inherit modules;
                    system = "x86_64-linux";
                    specialArgs = inputs;
                  };

                hm = import (
                  (pkgs.applyPatches {
                    name = "home-manager-patched";
                    src = inputs.home-manager;
                    patches = map pkgs.fetchpatch hmPatches;
                  })
                  + "/nixos/default.nix"
                );
              in
              {
                # Systemd machines
                prime = buildSystem ([ ./workstations/infra/prime ] ++ workstationModules);
                probook = buildSystem ([ ./workstations/infra/probook ] ++ workstationModules);
                mini = buildSystem ([ ./workstations/infra/mini ] ++ workstationModules);
                # nixosvmtest = unstableSystem ([ ./homelab/infra/nixosvmtest.nix ] ++ commonModules);
                thinkcentre = buildSystem ([ ./homelab/infra/thinkcentre ] ++ homelabSys);
                itxserve = buildSystem ([ ./homelab/infra/itxserve ] ++ homelabSys);
              }
            );
          };

        perSystem =
          {
            config,
            pkgs,
            lib,
            system,
            ...
          }:
          {
            # devshells
            make-shells.default = {
              packages = with pkgs; [
                nixfmt-rfc-style
                nil
                nix-tree
              ];
            };
            # Formatting for all the things
            treefmt =
              { ... }:
              {
                projectRootFile = "flake.nix";

                programs = {
                  nixfmt.enable = true;
                  jsonfmt.enable = true;
                  mdformat.enable = true;
                };

                settings.global.excludes = [
                  "*.age"
                  "*.ldif"
                  "*.envrc"
                  "*.css"
                ];
              };

            checks = # nixosConfigurations.machine -> nixosConfigurations-machine
              (
                lib.filterAttrs (lib.const (deriv: deriv.system == system)) (
                  lib.mapAttrs' (
                    name: value: lib.nameValuePair "nixosConfigurations-${name}" value.config.system.build.toplevel
                  ) self.nixosConfigurations
                )
              );
          };
      }
    );
}
