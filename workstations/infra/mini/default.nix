{ config, pkgs, ... }:
let
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [
    pc
    laptop
  ];
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "mini";

  workstation = {
    declarativeHome = false;
    desktop = "gnome";
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  environment.sessionVariables.NH_FLAKE = "/home/mini/repos/nixos";

  console.keyMap = "uk";
  users.users.mini = {
    openssh.authorizedKeys.keys = workstations;
    isNormalUser = true;
    description = "mini";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services = {
    displayManager.autoLogin = {
      user = "mini";
      enable = true;
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    printing.drivers = with pkgs; [ cnijfilter2 ];
  };

  system.stateVersion = "24.05";
}
