{ ...
}:

{
  imports = [ ./hardware-configuration.nix ./nextcloud.nix ./openldap.nix ];

  networking = {
    hostName = "nixos-thinkcentre-tiny";
    firewall = {
      enable = true;
      interfaces."eno1" = {
        allowedTCPPorts = [ 80 443 389 636 ];
      };
    };
  };
}
