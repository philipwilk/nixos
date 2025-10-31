{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    obs-studio
    gimp
    krita
    rawtherapee
    kdePackages.kdenlive
    video-trimmer
    blender
  ];
}
