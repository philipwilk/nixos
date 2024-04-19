{ pkgs, config, lib, agenix, ... }:
let
  homelab = config.homelab;
  conf = homelab.services.mediawiki;
in {
  config = lib.mkIf conf.enable {
    age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
    age.secrets = {
      mediawiki_sec = {
        file = ../../secrets/mediawiki_sec.age;
        owner = "mediawiki";
      };
      mediawiki_password = {
        file = ../../secrets/mediawiki_password.age;
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
          'microsoft' => [
            'clientId'                => '2f2cd144-8aec-4852-8571-e52903438ef2',
            'clientSecret'            => file_get_contents("${config.age.secrets.mediawiki_sec.path}"),
            'urlAuthorize'            => 'https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize',
            'urlAccessToken'          => 'https://login.microsoftonline.com/organizations/oauth2/v2.0/token',
            'urlResourceOwnerDetails' => 'https://graph.microsoft.com',
            'scopes' => 'openid email profile'
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
