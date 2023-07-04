{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , ...
    } @ inputs:
    {
      nixosConfigurations = {
        nixowos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./machines/nixowos/configuration.nix ./machines/nix-settings.nix ./machines/uk-region.nix ./machines/workstation.nix ];
        };
        nixowos-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./machines/nixowos-laptop/configuration.nix ./machines/nix-settings.nix ./machines/uk-region.nix ./machines/workstation.nix ];
        };
      };
    };
}
