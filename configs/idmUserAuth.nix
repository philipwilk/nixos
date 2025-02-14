{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.idmUserAuth;
in
{
  options.system.idmUserAuth = {
    enable = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = "Authentication using the configured idm provider";
    };
    idmDomain = lib.mkOption {
      description = "Domain for PAM/NSS authentication";
      default = "testing-idm.fogbox.uk";
      type = lib.types.str;
    };
    allowedGroups = lib.mkOption {
      description = "Groups that are allowed to login";
      default = [ "posix_allowed" ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    users.mutableUsers = false;
    services.kanidm = {
      enablePam = true;
      clientSettings.uri = "https://${cfg.idmDomain}";
      unixSettings = {
        pam_allowed_login_groups = cfg.allowedGroups;
        version = "2";
        kanidm = {
          pam_allowed_login_groups = cfg.allowedGroups;
          map_group = [
            {
              local = "wheel";
              "with" = "posix_wheel";
            }
          ];
        };
      };
    };
    services.openssh.authorizedKeysCommand = "/etc/ssh/getAuthedKeys %u";

    environment.etc."ssh/getAuthedKeys" = {
      mode = "0555";
      text = ''
        #!${pkgs.stdenv.shell}
        ${lib.getExe' pkgs.kanidm "kanidm_ssh_authorizedkeys"} $1
      '';
    };
  };
}
