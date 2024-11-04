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
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      agenix,
      nix-matlab,
      home-manager,
      catppuccin,
      nixos-generators,
      lanzaboote,
      buildbot-nix,
      treefmt-nix,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
      join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);

      treefmtEval = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      # Regional and nix settings for all machines
      commonModules = join-dirfile "configs" [
        "nix-settings"
        "uk-region"
      ];

      # Homelab
      homelabSys = commonModules ++ [
        ./homelab
        agenix.nixosModules.default
        ./homelab/config.nix
        buildbot-nix.nixosModules.buildbot-master
        buildbot-nix.nixosModules.buildbot-worker
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
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          catppuccin.nixosModules.catppuccin
          lanzaboote.nixosModules.lanzaboote
          ./workstations
        ];

      buildSys =
        nxpkgs: mods:
        nxpkgs.lib.nixosSystem {
          modules = mods;
          specialArgs = inputs;
        };

      unstableSystem = buildSys nixpkgs;
      stableSystem = buildSys nixpkgs-stable;

      buildIso =
        arch: mods:
        nixos-generators.nixosGenerate {
          system = arch;
          modules = [ ./cluster ] ++ commonModules ++ mods;
          specialArgs = inputs;
          format = "iso";
        };
      buildX86Iso = buildIso "x86_64-linux";

      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
    {
      # packages.x86_64-linux = {
      # new-client = buildX86Iso [ ./cluster/client/new.nix ];
      # };

      nixosConfigurations = {
        # Systemd machines
        prime = unstableSystem ([ ./workstations/infra/prime ] ++ workstationModules);

        probook = unstableSystem ([ ./workstations/infra/probook ] ++ workstationModules);

        mini = unstableSystem ([ ./workstations/infra/mini ] ++ workstationModules);

        # nixosvmtest = unstableSystem ([ ./homelab/infra/nixosvmtest.nix ] ++ commonModules);

        thinkcentre = unstableSystem ([ ./homelab/infra/thinkcentre ] ++ homelabSys);
        itxserve = unstableSystem ([ ./homelab/infra/itxserve ] ++ homelabSys);
      };

      formatter = forAllSystems (nixpkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = forAllSystems (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      devShells."x86_64-linux".default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nix-tree
        ];
      };
    };
}
