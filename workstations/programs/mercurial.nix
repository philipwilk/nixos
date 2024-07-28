{ config, lib, ... }:
{
  config = lib.mkIf config.workstation.declarativeHome {
    home-manager.users.philip.programs.mercurial = lib.mkIf config.workstation.declarativeHome {
      enable = true;
      userName = config.workstation.sourceControl.userName;
      userEmail = config.workstation.sourceControl.userEmail;
    };
  };
}
