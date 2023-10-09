{ pkgs
, lib
, ...
}:
{
  programs.git = {
    enable = true;
    userName = "Philip Wilk";
    userEmail = "p.wilk@student.reading.ac.uk";
    aliases = {
      pl = "log --graph --abbrev-commit --decorate --stat";
    };
    diff-so-fancy.enable = true;
    signing = {
      signByDefault = true;
      key = "/home/philip/.ssh/gitKey";
    };
    extraConfig = {
      core = {
        editor = "hx";
        sshCommand = "ssh -i /home/philip/.ssh/gitKey";
      };
      gpg = {
        format = "ssh";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      ssh = {
        identity = "/home/philip/.ssh/gitKey";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
