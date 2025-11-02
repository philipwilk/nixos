{
  ...
}:
{
  wsl.defaultUser = "wslphilip";
  flakeConfig.environment.primaryHomeManagedUser = "wslphilip";

  home-manager.users."wslphilip".imports = [
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
