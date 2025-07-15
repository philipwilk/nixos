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
          inputs.home-manager.flakeModules.home-manager
        ];

        systems = [
          "x86_64-linux"
        ];

        flake =
          {
            lib,
            pkgs,
            ...
          }:
          {
            nixosConfigurations = withSystem "x86_64-linux" (
              {
                pkgs,
                system,
                ...
              }:
              let
                mkSystemFactory =
                  classModules: hostModule:
                  inputs.nixpkgs.lib.nixosSystem {
                    inherit system;
                    modules = classModules ++ [
                      ./overlays
                      ./nixosModules
                      inputs.agenix.nixosModules.default
                      (
                        { ... }:
                        {
                          networking.hostName = lib.mkDefault (builtins.baseNameOf hostModule);
                        }
                      )
                      hostModule
                    ];
                    specialArgs = inputs;
                  };

                mkWorkstationSystem = mkSystemFactory [
                  ./overlays/workstation.nix
                  ./nixosModules/workstation.nix
                  inputs.home-manager.nixosModules.default
                  inputs.lanzaboote.nixosModules.lanzaboote
                ];

                mkHomelabSystem = mkSystemFactory [
                  ./overlays/homelab.nix
                  ./nixosModules/homelab.nix
                  inputs.buildbot-nix.nixosModules.buildbot-master
                  inputs.buildbot-nix.nixosModules.buildbot-worker
                ];

              in
              (lib.mkMerge [
                (lib.attrsets.genAttrs [
                  "prime"
                  "probook"
                  "mini"
                  #"nixosvmtest"
                ] (hostname: mkWorkstationSystem ./nixosModules/workstation/infra/${hostname}))
                (lib.attrsets.genAttrs [
                  "thinkcentre"
                  "itxserve"
                  "rdg"
                ] (hostname: mkHomelabSystem ./nixosModules/homelab/infra/${hostname}))
              ])
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
                  (lib.mapAttrs' (
                    name: value: lib.nameValuePair "nixosConfigurations-${name}" value.config.system.build.toplevel
                  ) self.nixosConfigurations)
                )
              );
          };
      }
    );
}
