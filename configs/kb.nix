{
  pkgs,
  ...
}:
{
  i18n.inputMethod.ibus.engines = with pkgs; [
    rime
  ];
}
