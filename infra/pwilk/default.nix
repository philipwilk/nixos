{
  ...
}:
{
  wsl.defaultUser = "pwilk";
  flakeConfig.environment.primaryHomeManagedUser = "pwilk";
  hjem.users.pwilk.enable = true;
  hjem.users.pwilk.localDef.programs.git = {
    email = "philip.wilk@fivium.co.uk";
    signingKey = "/home/pwilk/.ssh/gitKey";
  };

  system.stateVersion = "25.05";
}
