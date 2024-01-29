{ ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  homelab = {
    enable = true;
    isLeader = true;
  };

  networking = {
    hostName = "nixos-thinkcentre-tiny";
    firewall = {
      enable = true;
      interfaces."eno1" = {
        allowedTCPPorts = [ 80 443 ];
      };
    };
  };
}
