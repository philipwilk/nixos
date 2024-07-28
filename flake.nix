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
      ...
    }@inputs:
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
      homelabModules = commonModules ++ [
        ./homelab
        agenix.nixosModules.default
        ./homelab/config.nix
        buildbot-nix.nixosModules.buildbot-master
        buildbot-nix.nixosModules.buildbot-worker
      ];
      systemdLab = homelabModules ++ [ ./configs/boot/systemd.nix ];
      grubLab = homelabModules ++ [ ./configs/boot/grub.nix ];

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
        nixowos = unstableSystem ([ ./workstations/infra/nixowos ] ++ workstationModules);

        nixowos-laptop = unstableSystem ([ ./workstations/infra/nixowos-laptop ] ++ workstationModules);

        mini = unstableSystem ([ ./workstations/infra/mini ] ++ workstationModules);

        # nixosvmtest = unstableSystem ([ ./homelab/infra/nixosvmtest.nix ] ++ commonModules);

        nixos-thinkcentre-tiny = unstableSystem ([ ./homelab/infra/nixos-thinkcentre-tiny ] ++ systemdLab);

        # Grub machines (DO NOT SUPPORT EFI BOOT)
        hp-dl380p-g8-LFF = unstableSystem (
          [
            ./homelab/infra/hp-dl380p-g8-LFF
            # ./homelab/services/minecraft.nix
          ]
          ++ grubLab
        );

        # hp-dl380p-g8-sff-2 = unstableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-2 ] ++ grubLab);

        # hp-dl380p-g8-sff-3 = unstableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-3 ] ++ grubLab);

        # hp-dl380p-g8-sff-4 = unstableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-4 ] ++ grubLab);

        # hp-dl380p-g8-sff-5 = unstableSystem ([ ./homelab/infra/hp-dl380p-g8-sff-5 ] ++ grubLab);
      };
      formatter = forAllSystems (nixpkgs: nixpkgs.nixfmt-rfc-style);

      devShells."x86_64-linux".default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nix-tree
        ];
      };
    };
}
