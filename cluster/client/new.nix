{
	pkgs,
	lib,
	config,
	...
}:
{
	autonix = {
		serverUrl = "deploy.fogbox.uk";
		additionalKeys =
			let
	      pc =
	        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
	      laptop =
	        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
	      workstations = [ pc laptop ];
	    in
				workstations;
		client = {
			awaitingEnroll = true;
			otp = "sample";
		};
	};

  system.stateVersion = "24.05";
}
