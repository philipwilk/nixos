{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ciscoPacketTracer8
  ];
}
