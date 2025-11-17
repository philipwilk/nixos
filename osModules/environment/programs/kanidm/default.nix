{
  pkgs,
  ...
}:
{
  services.kanidm = {
    enableClient = true;
    package = pkgs.kanidm_1_8;
    clientSettings.uri = "https://testing-idm.fogbox.uk";
  };
}
