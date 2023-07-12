{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , agenix
    , ...
    } @ inputs:
    {
      nixosConfigurations = {
        nixowos = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./machines/nixowos/configuration.nix ./machines/boot-options.nix ./machines/nix-settings.nix ./machines/uk-region.nix ./machines/workstation.nix agenix.nixosModules.default ];
        };
        nixowos-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./machines/nixowos-laptop/configuration.nix ./machines/boot-options.nix ./machines/nix-settings.nix ./machines/uk-region.nix ./machines/workstation.nix agenix.nixosModules.default ];
        };
        nixos-thinkcentre-tiny = nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [ ./machines/nixos-thinkcentre-tiny/configuration.nix ./machines/boot-options.nix ./machines/nix-settings.nix ./machines/uk-region.nix agenix.nixosModules.default ];
        };
      };
    };
}
