{
  pkgs,
  ...
}:
{
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  environment.systemPackages = with pkgs; [
    ventoy-full
  ];
}
