{
	lib,
	pkgs,
	config,
	...
}:
{
	options.autonix.server = {
		
	};
	
  config = lib.mkIf (config.options.autonix.role == "server") {
    
  };
}
