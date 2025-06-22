{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.jupyterhub;
in
{
  options.homelab.services.jupyterhub.enable = lib.mkEnableOption "the JupyterHub server";

  config = lib.mkIf cfg.enable {
    age.secrets.jupyter-envs.file = ../../secrets/jupyter-envs.age;

    # oauth client secret is provided via env OAUTH_CLIENT_SECRET
    systemd.services.jupyterhub.serviceConfig.EnvironmentFile = config.age.secrets.jupyter-envs.path;

    services.jupyterhub = {
      enable = true;
      extraConfig =
        let
          idm_domain = "https://testing-idm.fogbox.uk";
        in
        ''
          c.Spawner.http_timeout = 60
          c.JupyterHub.spawner_class = 'systemd'
          c.SystemdSpawner.readwrite_paths = ['/home/{USERNAME}']

          c.JupyterHub.authenticator_class = 'generic-oauth'
          c.GenericOAuthenticator.client_id = 'jupyterhub'
          c.GenericOAuthenticator.oauth_callback_url = 'https://notebooks.${config.homelab.tld}/hub/oauth_callback'
          c.GenericOAuthenticator.login_service = 'KanIDM'
          c.GenericOAuthenticator.auto_login = True
          c.GenericOAuthenticator.authorize_url = '${idm_domain}/ui/oauth2'
          c.GenericOAuthenticator.token_url = "${idm_domain}/oauth2/token"
          c.GenericOAuthenticator.userdata_url = "${idm_domain}/oauth2/openid/jupyterhub/userinfo"
          c.GenericOAuthenticator.scope = ['openid', 'email', 'groups']
          c.GenericOAuthenticator.auth_state_groups_key = 'oauth_user.groups'
          c.GenericOAuthenticator.username_claim = 'preferred_username'
          c.GenericOAuthenticator.manage_groups = True
          c.GenericOAuthenticator.allowed_groups = { 'idm_all_persons@testing-idm.fogbox.uk' }
          c.GenericOAuthenticator.admin_groups = { 'idm_people_admins@testing-idm.fogbox.uk' }
        '';
      jupyterhubEnv = pkgs.python3.withPackages (
        p: with p; [
          jupyterhub
          jupyterhub-systemdspawner
          oauthenticator
        ]
      );
      jupyterlabEnv = pkgs.python3.withPackages (
        p: with p; [
          (jupyterhub.overridePythonAttrs (previousAttrs: {
            dependencies = previousAttrs.dependencies ++ [ pkgs.git ];
          }))
          jupyterlab
          python-lsp-server
          jupyterlab-git
          ipympl
        ]
      );
      kernels.python3 =
        let
          env = (
            pkgs.python312.withPackages (
              pythonPackages: with pythonPackages; [
                nbclassic
                pandas
                matplotlib
                scikit-learn
                seaborn
                networkx
                plotly
                cartopy
                xarray
                joblib
                netcdf4
                ipython
                pyquerylist
                statsmodels
                tensorflow
                mlxtend
                imbalanced-learn
                graphviz
                pydot
                gymnasium
                flask
                django
                opencv-python
                psycopg2
                html5lib

                ipympl
              ]
            )
          );
        in
        {
          displayName = "Python 3 for ML";
          argv = [
            "${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          env = {
            TF_ENABLE_ONEDNN_OPTS = "0";
          };
          language = "python";
          logo32 = "${env}/${env.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 = "${env}/${env.sitePackages}/ipykernel/resources/logo-64x64.png";
        };
    };

    services.nginx.virtualHosts."notebooks.${config.homelab.tld}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.jupyterhub.port}";
        proxyWebsockets = true;
      };
    };
  };
}
