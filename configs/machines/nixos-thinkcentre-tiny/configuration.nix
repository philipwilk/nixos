{ ...
}:

{
  imports = [ ./hardware-configuration.nix ./nextcloud.nix ];

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
