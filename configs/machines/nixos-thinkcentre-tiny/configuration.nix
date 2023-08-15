{ ...
}:

{
  imports = [ ./hardware-configuration.nix ];

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
