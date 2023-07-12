{ pkgs
, ...
}:

{
  imports = [ ./hardware-configuration.nix ./nextcloud.nix ];

  networking = {
    hostName = "nixos-thinkcentre-tiny";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      interfaces."eno1" = {
        allowedTCPPorts = [ 80 443 ];
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philip = {
    isNormalUser = true;
    description = "philip";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ helix ];
  };

  # Enable openssh server
  services.openssh.enable = true;
  # intel microcode update
  hardware.cpu.intel = {
    updateMicrocode = true;
    sgx.provision.enable = true;
  };
  # Cpu governor
  powerManagement.cpuFreqGovernor = "ondemand";
  # Enable virtualisation w/ podman
  virtualisation.podman.enable = true;
}
