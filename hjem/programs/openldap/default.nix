{
  lib,
  config,
  ...
}:
{
  options.localDef.programs.openldap.enable = lib.mkEnableOption "openldap";

  config = lib.mkIf config.localDef.programs.openldap.enable {
    files.".ldaprc".text = ''
      BASE dc=ldap,dc=fogbox,dc=uk
      URI ldaps://ldap.fogbox.uk
      BINDDN cn=admin,dc=ldap,dc=fogbox,dc=uk
    '';
  };
}
