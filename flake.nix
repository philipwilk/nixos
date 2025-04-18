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
    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
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
                join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);

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

                patches = [
                  # {
                  #   meta.description = "description for the patch" ;
                  #   url = "";
                  #   hash = "";
                  # }
                  {
                    meta.description = "fix mlxtend";
                    url = "https://github.com/NixOS/nixpkgs/pull/392453.patch";
                    hash = "sha256-8UM38Km67vHmUmFlFsHFZy5ESqgB+15xbNbIRSMnPAM=";
                  }
                  {
                    meta.description = "fix imbalanced-learn";
                    url = "https://github.com/NixOS/nixpkgs/pull/392405.patch";
                    hash = "sha256-jHshSGpZs+MkwP4S2j0eMihwHjn3SdcGEL78MYRRhD0=";
                  }
                  {
                    meta.description = "nixos/hddfancontrol: use attrset for config";
                    url = "https://github.com/NixOS/nixpkgs/pull/394826.patch";
                    hash = "sha256-nV5kn94h4v66Lj5/IWYyoByfs/OIbIXwfp8+SzPw3eE=";
                  }
                  {
                    meta.descripiton = "stalwart-mail: disable failing tests";
                    url = "https://github.com/NixOS/nixpkgs/pull/398434.patch";
                    hash = "sha256-jpCDvcHMkZz/dMe/izMWSv1O3JkXtMhO7JUhptii2Xo=";
                  }
                ];

                hmPatches = [
                ];

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
