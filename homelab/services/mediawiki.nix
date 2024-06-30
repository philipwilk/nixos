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
      mediawiki_gh_sec = {
        file = ../../secrets/mediawiki_gh_sec.age;
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
            'urlAuthorize'            => 'https://login.microsoftonline.com/organizations/oauth2/authorize',
            'urlAccessToken'          => 'https://login.microsoftonline.com/organizations/oauth2/token',
            'urlResourceOwnerDetails' => 'https://graph.microsoft.com',
            'scopes' => 'openid email profile'
          ],
          'github' => [
            'clientId'                => 'Iv1.7af0811556d82ff5',
            'clientSecret'            => file_get_contents("${config.age.secrets.mediawiki_gh_sec.path}"),
            'urlAuthorize'            => 'https://github.com/login/oauth/authorize',
            'urlAccessToken'          => 'https://github.com/login/oauth/access_token',
            'urlResourceOwnerDetails' => 'https://api.github.com/user'
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
