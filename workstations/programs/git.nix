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
      dh = "diff HEAD";
      dhp = "diff HEAD~";
    };
    diff-so-fancy.enable = true;
    signing = {
      signByDefault = true;
      key = "/home/philip/.ssh/gitKey";
    };
    extraConfig = {
      core = {
        editor = "hx";
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
      init = {
        defaultBranch = "main";
      };
      rerere.enabled = true;
    };
  };
}
