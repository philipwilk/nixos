{
  pkgs,
  ...
}:
{
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      wl-clipboard
      wl-clip-persist
    ];
  };
}
