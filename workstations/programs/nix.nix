{ config, ... }: {
  home.file."${config.xdg.configHome}/nixpkgs/config.nix".text =
    "{ allowUnfree = true; }";
}
