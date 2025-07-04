{
  pkgs,
  config,
  lib,
  agenix,
  ...
}:
let
  homelab = config.homelab;
  conf = homelab.services.mediawiki;
in
{
  options.homelab.services.mediawiki = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the mediawiki server.
      '';
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "wiki.${config.homelab.tld}";
      example = "wiki.example.com";
      description = ''
        Domain of the wiki.
      '';
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = "Mediawiki";
      example = "Example wiki";
      description = ''
        Name of the wiki.
      '';
    };
    adminMail = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.acme.mail;
      example = "admin@example.com";
      description = ''
        Email of the admin of the wiki (for the web server)
      '';
    };
  };
  config = lib.mkIf conf.enable {
    age.secrets = {
      mediawiki_password = {
        file = ../../../secrets/mediawiki/password.age;
        owner = "mediawiki";
      };
      mediawiki_gh = {
        file = ../../../secrets/mediawiki/gh.age;
        owner = "mediawiki";
      };
      mediawiki_gl = {
        file = ../../../secrets/mediawiki/gl.age;
        owner = "mediawiki";
      };
    };

    services.mediawiki = {
      enable = true;
      name = conf.name;
      webserver = "nginx";
      nginx.hostName = conf.domain;
      extensions = {
        AuthManagerOAuth = pkgs.fetchzip {
          url = "https://github.com/mohe2015/AuthManagerOAuth/releases/download/v0.3.2/AuthManagerOAuth.zip";
          hash = "sha256-hr/DLyL6IzQs67eA46RdmuVlfCiAbq+eZCRLfjLxUpc=";
        };
        SyntaxHighlight_GeSHi = null;
        ParserFunctions = null;
        Cite = null;
        VisualEditor = null;
        ConfirmEdit = null;
      };
      passwordFile = config.age.secrets.mediawiki_password.path;
      # Actual wiki config
      extraConfig = ''
        $wgUsePathInfo = true;

        $wgEnableUploads = true;
        $wgGenerateThumbnailOnParse = false;

        $wgAllowExternalImages = true;

        $wgGroupPermissions['*']['edit'] = false;

        $wgGroupPermissions['cancreateuser']['bot'] = false;

        # for visual editor
        $wgGroupPermissions['user']['writeapi'] = true;

        // oauth2 config
        $wgAuthManagerOAuthConfig = [
          'gitlab' => [
            'clientId' => '917e25cf997484f5e42cf82f94523497fe7cc7bc00627b9afd8d53b3b6e77a8c',
            'clientSecret' => file_get_contents("${config.age.secrets.mediawiki_gl.path}"),
            'urlAuthorize' => 'https://csgitlab.reading.ac.uk/oauth/authorize',
            'urlAccessToken' => 'https://csgitlab.reading.ac.uk/oauth/token',
            'urlResourceOwnerDetails' => 'https://csgitlab.reading.ac.uk/oauth/userinfo',
            'scopes' => 'openid email profile',
          ],
        ];        
      '';
    };
    services.nginx.virtualHosts.${conf.domain} = {
      enableACME = lib.mkDefault true;
      forceSSL = lib.mkDefault true;
    };
  };
}
