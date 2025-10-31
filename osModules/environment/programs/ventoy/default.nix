{
  pkgs,
  ...
}:
{
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];

  environment.systemPackages = with pkgs; [
    ventoy-full
  ];
}
