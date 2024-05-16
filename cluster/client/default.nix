{
	lib,
	pkgs,
	config,
	...
}:
let
  mkOpt = lib.mkOption;
  t = lib.types;
in
{
	options.autonix.client = {
		otp = mkOpt {
			type = t.str;
			default = null;
			example = "";
			description =  ''
				The otp to auth with the server to allow enrollment to the cluster.
			'';
		};
		awaitingEnroll = mkOpt {
			type = t.bool;
			default = false;
			example = true;
			description = ''
				Whether the system needs to enroll. Should only be true prior to registration.
			'';
		};
	};
	
  config = lib.mkIf (config.autonix.role == "client") {
    assertions = [{
      assertion = config.autonix.client.awaitingEnroll == true
        -> config.autonix.client.otp != null;
      message = "Autonix client registration requires an otp.";
    }];		
  };
}
