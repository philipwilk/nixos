{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.workstation.declarativeHome {
    home-manager.users.philip.programs.git = lib.mkIf config.workstation.declarativeHome {
      enable = true;
      userName = config.workstation.sourceControl.userName;
      userEmail = "p.wilk@student.reading.ac.uk";
      aliases = {
        pl = "log --graph --abbrev-commit --decorate --stat";
        dh = "diff HEAD";
        dhp = "diff HEAD~";
        push-fwl = "push --force-with-lease";
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
  };
}
