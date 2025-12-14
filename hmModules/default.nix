{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.hmOptions = {
    sourceControl = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Philip Wilk";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "p.wilk@student.reading.ac.uk";
      };
    };
  };

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
      bat.enable = true;
      bottom.enable = true;
      carapace.enable = true;
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
      mercurial = {
        enable = true;
        userName = config.hmOptions.sourceControl.name;
        userEmail = config.hmOptions.sourceControl.email;
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
      diff-so-fancy = {
        enable = true;
        enableGitIntegration = true;
      };
      git = {
        enable = true;
        signing = {
          signByDefault = lib.mkDefault true;
          key = "${config.home.homeDirectory}/.ssh/gitKey";
        };
        settings = {
          user = {
            name = config.hmOptions.sourceControl.name;
            email = config.hmOptions.sourceControl.email;
          };
          alias = {
            pl = "log --graph --abbrev-commit --decorate --stat";
            dh = "diff HEAD";
            dhp = "diff HEAD~";
            push-fwl = "push --force-with-lease";
            rhp = "reset HEAD~";
            rhph = "reset HEAD~ --hard";
            rhh = "reset HEAD --hard";
          };
          core = {
            editor = "hx";
          };
          gpg = {
            format = "ssh";
          };
          pull = {
            rebase = true;
          };
          push = {
            autoSetupRemote = true;
          };
          init = {
            defaultBranch = "main";
          };
          rerere.enabled = true;
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
