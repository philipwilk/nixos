{ pkgs
, ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos";

  hardware = {
    cpu.amd = {
      updateMicrocode = true;
      sev.enable = true;
    };
    bluetooth.settings.General = {
      FastConnectable = true;
      ReconnectAttempts = 7;
      ReconnectIntervals = "1, 2, 3";
    };
  };

  users.users.philip = {
    extraGroups = [ "corectrl" ];
    packages = with pkgs; [
      via # for keyboards
    ];
  };

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
