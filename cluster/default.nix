{
  pkgs,
  lib,
  config,
  ...
}:
let
  mkOpt = lib.mkOption;
  t = lib.types;
  mdDoc = lib.mkDoc;
in
{
  imports = [
    ./server
    ./client
  ];
  
  options.autonix = {
    role = mkOpt {
      type = t.enum [ "client" "server" ];
      default = "client";
      example = "server";
      description = mdDoc ''
        Server if this machine is creating images, serving them and acting as the control server.
        Client if this machine is taking an image, doing a fresh install and sending its hardware config.
      '';
    };
    serverUrl = mkOpt {
      type = t.str;
      default = null;
      example = "deploy.fogbox.uk";
      description = mdDoc ''
        The url to send client enrolls to (aka the server).
      '';
    };
    additionalKeys = mkOpt {
      type = t.listOf t.str;
      default = [];
      example = [ "SHA256:RLy4JBv7jMK5qYhRKwHB3af0rpMKYwE2PBhALCBV3G8 username@hostname" ];
      description = mdDoc ''
        Additional public keys to add to clients for ssh auth.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = config.autonix.role != null -> config.autonix.serverUrl != null;
        message = "Autonix requires a callback server url.";
      }
      {
        assertion = config.autonix.role != null -> config.autonix.additionalKeys != [];
        message = "Autonix requires additional ssh keys so you can connect to the servers after install.";
      }
    ];

		services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
		boot.kernelPackages = pkgs.linuxPackages_latest;
    users.users.nixos = {
      isNormalUser = true;
      initialPassword = "";
      openssh.authorizedKeys.keys = config.autonix.additionalKeys;
    };
  	security.pam.services.nixos.allowNullPassword = true;
    users.groups.nixos = {};
  };
}
