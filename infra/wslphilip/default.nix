{
  ...
}:
{
  wsl.defaultUser = "wslphilip";
  flakeConfig.environment.primaryHomeManagedUser = "wslphilip";
  hjem.users.wslphilip.enable = true;
  hjem.users.wslphilip.localDef.programs.git.signingKey = "/home/wslphilip/.ssh/gitKey";

  system.stateVersion = "25.05";
}
