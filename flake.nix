{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix = {
      url = "github:yaxitech/ragenix";
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
    in
    {
      nixosConfigurations = {
        nixowos = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/nixowos/configuration.nix
            ./configs/boot/systemd.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/kb.nix
            ./configs/workstation.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ./configs/home-manager/hm-settings.nix
            catppuccin.nixosModules.catppuccin
          ];
        };
        nixowos-laptop = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/nixowos-laptop/configuration.nix
            ./configs/boot/systemd.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/kb.nix
            ./configs/workstation.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ./configs/home-manager/hm-settings.nix
            catppuccin.nixosModules.catppuccin
          ];
        };
        nixos-thinkcentre-tiny = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/nixos-thinkcentre-tiny/configuration.nix
            ./configs/boot/systemd.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            ./configs/services/nextcloud.nix
            ./configs/services/openldap.nix
            ./configs/services/navidrome.nix
            ./configs/services/factorio.nix
            agenix.nixosModules.default
          ];
        };
        hp-dl380p-g8-LFF = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/hp-dl380p-g8-LFF/configuration.nix
            ./configs/boot/grub.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            agenix.nixosModules.default
          ];
        };
        hp-dl380p-g8-sff-2 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/hp-dl380p-g8-sff-2/configuration.nix
            ./configs/boot/grub.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            agenix.nixosModules.default
          ];
        };
        hp-dl380p-g8-sff-3 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/hp-dl380p-g8-sff-3/configuration.nix
            ./configs/boot/grub.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            agenix.nixosModules.default
          ];
        };
        hp-dl380p-g8-sff-4 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/hp-dl380p-g8-sff-4/configuration.nix
            ./configs/boot/grub.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            agenix.nixosModules.default
          ];
        };
        hp-dl380p-g8-sff-5 = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./configs/machines/hp-dl380p-g8-sff-5/configuration.nix
            ./configs/boot/grub.nix
            ./configs/nix-settings.nix
            ./configs/uk-region.nix
            ./configs/server.nix
            agenix.nixosModules.default
          ];
        };
      };
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
