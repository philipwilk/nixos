{
  config,
  pkgs,
  ...
}:
{
  age.secrets.workVpnConfig.file = ../../../../secrets/openvpn/work/config.age;
  age.secrets.workVpnCreds.file = ../../../../secrets/openvpn/work/creds.age;
  services.openvpn.servers.work = {
    autoStart = false;
    config = "config ${config.age.secrets.workVpnConfig.path}";
    authUserPass = config.age.secrets.workVpnCreds.path;
  };

  systemd.services."openvpn-work".serviceConfig = {
    StandardInput = "tty1";
    StandardOutput = "tty1";
    TTYPath = "/dev/tty1";
  };

  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];
}
