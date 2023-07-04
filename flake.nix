{
  description = "system definitions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "nixowos" = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./machines/${self.hostName}/configuration.nix];
      };
    };
  };
}
