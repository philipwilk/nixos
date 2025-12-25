{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./i18n
    ./programs/kakoune
    ./programs/fish
  ];

  config = {
    home = {
      packages = with pkgs; [
        (catppuccin.override {
          accent = "peach";
          variant = "latte";
        })
      ];
    };

    programs = {
      home-manager.enable = true;
      starship.enable = true;
      helix.enable = true;
      nix-index-database.comma.enable = true;
      command-not-found.enable = false;

      eza = {
        enable = true;
        git = true;
        enableFishIntegration = true;
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = {
          global = {
            warn_timeout = "0s";
            hide_env_diff = true;
            load_dotenv = true;
          };
        };
      };
      skim = {
        enable = true;
        enableFishIntegration = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
            identityFile = [ "~/.ssh/id_ed25519" ];
          };

          csgitlab = {
            host = "csgitlab.reading.ac.uk";
            identitiesOnly = true;
          };
          legacy-csgitlab = {
            host = "csgitlab-legacy.reading.ac.uk";
            identitiesOnly = true;
          };
          github = {
            host = "github.com";
            identitiesOnly = true;
          };
          fogbox = {
            host = "fogbox.uk";
            identitiesOnly = true;
            port = 22420;
          };
          rdg-fogbox = {
            host = "rdg.uk.region.fogbox.uk";
            identitiesOnly = true;
            port = 22420;
          };
          sou-fogbox = {
            host = "sou.uk.region.fogbox.uk";
            identitiesOnly = true;
            port = 22420;
          };
          fogbox-git = {
            host = "git.fogbox.uk";
            identitiesOnly = true;
          };
        };
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = false;
        settings = {
          git_protocol = "ssh";
        };
      };
      gh-dash = {
        enable = true;
        settings = { };
      };
    };

    catppuccin = {
      enable = true;
      flavor = "latte";
      bat.enable = true;
      bottom.enable = true;
      chromium.enable = true;
      fcitx5.enable = true;
      fish.enable = true;
      fuzzel.enable = true;
      gh-dash.enable = true;
      helix.enable = true;
      kitty.enable = true;
      obs.enable = true;
      sway.enable = true;
      thunderbird.enable = true;
      waybar.enable = true;
    };

    services = {
      easyeffects.enable = true;
    };

    xdg.configFile."matlab/nix.sh".text = ''
      INSTALL_DIR=$HOME/Documents/matlab
    '';

    home.file = {
      ".ldaprc".text = ''
        BASE dc=ldap,dc=fogbox,dc=uk
        URI ldaps://ldap.fogbox.uk
        BINDDN cn=admin,dc=ldap,dc=fogbox,dc=uk
      '';
      "${config.xdg.configHome}/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
    };
  };
}
