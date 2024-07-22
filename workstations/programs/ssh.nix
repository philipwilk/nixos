{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      csgitlab = {
        host = "csgitlab.reading.ac.uk";
        identityFile = [ "~/.ssh/id_ed25519" ];
        identitiesOnly = true;
      };
      github = {
        host = "github.com";
        identityFile = [ "~/.ssh/id_ed25519" ];
        identitiesOnly = true;
      };
      fogbox = {
        host = "git.fogbox.uk";
        identityFile = [ "~/.ssh/id_ed25519" ];
        identitiesOnly = true;
        port = 22420;
      };
    };
  };
}
