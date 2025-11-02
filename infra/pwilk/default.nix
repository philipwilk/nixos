{
  ...
}:
{
  wsl.defaultUser = "pwilk";
  flakeConfig.environment.primaryHomeManagedUser = "pwilk";

  home-manager.users."pwilk".imports = [
    (
      {
        ...
      }:
      {
        home.stateVersion = "25.05";
      }
    )
  ];

  system.stateVersion = "25.05";
}
