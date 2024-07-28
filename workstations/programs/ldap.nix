{ ... }:
{
  home.file.".ldaprc".text = ''
    BASE dc=ldap,dc=fogbox,dc=uk
    URI ldaps://ldap.fogbox.uk
    BINDDN cn=admin,dc=ldap,dc=fogbox,dc=uk
  '';
}
