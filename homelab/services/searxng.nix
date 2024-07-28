{
    lib,
    config,
    pkgs,
    ...
}:
let
	domain = "search.${config.homelab.tld}";
in
{
    options.homelab.services.searxng.enable = lib.mkEnableOption "the searxng search engine";

    config = lib.mkIf config.homelab.services.searxng.enable {
        age.secrets.searxng_sec.file = ../../secrets/searxng/sec.age;
        
        services.nginx.virtualHosts.${domain} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
                extraConfig = ''
                  uwsgi_pass unix:${config.services.searx.uwsgiConfig.socket};
                '';
            };
        };

        systemd.services.nginx.serviceConfig.ProtectHome = false;
        users.groups.searx.members = [ "nginx" ];
        
        services.searx = {
            enable = true;
            package = pkgs.searxng;
            redisCreateLocally = true;

            limiterSettings = {
                real_ip = {
                x_for = 1;

                ipv4_prefix = 32;
                ipv6_prefix = 56;
              };
            botdetection = {
                ip_limit = {
                  filter_link_local = true;
                  link_token = true;
                };
                ip_lists = {
                  pass_ip = [
                    "192.168.0.0/16"
                    "fe80::/10"
                  ];
                  pass_searxng_org = true;
                };
              };
            };
            
            settings = {
                use_default_settings = true; 
                general = {
                    instance_name = "SearXNG";
                    #enable_metrics = false;
                };
                server = {
                    port = 8080;
                    bind_address = "0.0.0.0";
                    limiter = true;
                    image_proxy = true;
                    base_url = "https://${domain}";
                    public_instance = true;
                    default_locale = "en";
                    default_lang = "en-GB";
                    secret_key = config.age.secrets.searxng_sec.path;
                };
                ui = {
                    static_use_hash = true;
                    query_in_title = true;
                };
                search = {
                    safe_search = 0;
                    default_lang = "en-GB";
                    autocomplete = "duckduckgo";
                };
                enabled_plugins = [
                    "Hash plugin"
                    "Self Informations"
                    "Tracker URL remover"
                    "Ahmia blacklist"
                    "Open Access DOI rewrite"
                ];
                engines = lib.mapAttrsToList (name: value: {inherit name;} // value) {
                    "duckduckgo".disabled = false;
                    "brave".disabled = true;
                };
                outgoing = {
                    request_timeout = 5.0;
                    max_request_timeout = 15.0;
                    pool_connections = 100;
                    pool_maxsize = 15;
                    enable_http2 = true;
                };
            };
                
            runInUwsgi = true;
            
            uwsgiConfig = {
              socket = "/run/searx/searx.sock";
              http = ":8888";
              chmod-socket = "660";
              #disable-logging = true;
            };
        };
    };
}
