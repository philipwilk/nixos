{ pkgs, config, ... }: {
  age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
  age.secrets.server_password.file = ../secrets/server_password.age;

  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";
  virtualisation.podman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philip = {
    isNormalUser = true;
    description = "philip";
    extraGroups = [ "networkmanager" "wheel" ];
    passwordFile = config.age.secrets.server_password.path;
  };

  environment.systemPackages = with pkgs; [
    helix
    git
  ];

  hardware.cpu.intel = {
    updateMicrocode = true;
    sgx.provision.enable = true;
  };
}
