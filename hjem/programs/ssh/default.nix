{
  lib,
  config,
  ...
}:
{
  options.localDef.programs.ssh.enable = lib.mkEnableOption "ssh";

  config = lib.mkIf config.localDef.programs.ssh.enable {
    files.".ssh/config".text = ''
      Host csgitlab.reading.ac.uk
        IdentitiesOnly yes

      Host *.region.fogbox.uk
        Port 22420
        IdentitiesOnly yes

      Host git.fogbox.uk
        IdentitiesOnly yes

      Host github.com
        IdentitiesOnly yes

      Host csgitlab-legacy.reading.ac.uk
        IdentitiesOnly yes

      Host *
        ForwardAgent no
        ServerAliveInterval 0
        ServerAliveCountMax 3
        Compression no
        AddKeysToAgent no
        HashKnownHosts no
        UserKnownHostsFile ~/.ssh/known_hosts
        ControlMaster no
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist no
        IdentityFile ~/.ssh/id_ed25519
    '';
  };
}
