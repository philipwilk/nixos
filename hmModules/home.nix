{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    home.sourceControl = {
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
    ./i18n.nix
    ./kakoune.nix
    ./fish.nix
    ./sway.nix
  ];

  config = {

    home = {
      username = "philip";
      homeDirectory = "/home/philip";
      stateVersion = "24.05";
      packages = with pkgs; [
        (catppuccin.override {
          accent = "peach";
          variant = "latte";
        })
        adw-gtk3
        qadwaitadecorations
        qadwaitadecorations-qt6
      ];
      sessionVariables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_WAYLAND_DECORATION = "adwaita";
      };
    };

    gtk.gtk3.extraConfig.application-prefer-dark-theme = false;

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
      kitty = {
        enable = true;
        shellIntegration.enableFishIntegration = true;
        settings.confirm_os_window_close = 0;
      };
      mercurial = {
        enable = true;
        userName = config.home.sourceControl.name;
        userEmail = config.home.sourceControl.email;
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
          };
          csgitlab = {
            host = "csgitlab.reading.ac.uk";
            identityFile = [ "~/.ssh/csgitlab" ];
            identitiesOnly = true;
          };
          github = {
            host = "github.com";
            identityFile = [ "~/.ssh/id_ed25519" ];
            identitiesOnly = true;
          };
          fogbox = {
            host = "fogbox.uk";
            identityFile = [ "~/.ssh/id_ed25519" ];
            identitiesOnly = true;
            port = 22420;
          };
          rdg-fogbox = {
            host = "rdg.uk.region.fogbox.uk";
            identityFile = [ "~/.ssh/id_ed25519" ];
            identitiesOnly = true;
            port = 22420;
          };
          sou-fogbox = {
            host = "sou.uk.region.fogbox.uk";
            identityFile = [ "~/.ssh/id_ed25519" ];
            identitiesOnly = true;
            port = 22420;
          };
          fogbox-git = {
            host = "git.fogbox.uk";
            identityFile = [ "~/.ssh/id_ed25519" ];
            identitiesOnly = true;
          };
        };
      };
      git = {
        enable = true;
        userName = config.home.sourceControl.name;
        userEmail = config.home.sourceControl.email;
        aliases = {
          pl = "log --graph --abbrev-commit --decorate --stat";
          dh = "diff HEAD";
          dhp = "diff HEAD~";
          push-fwl = "push --force-with-lease";
          rhp = "reset HEAD~";
          rhph = "reset HEAD~ --hard";
          rhh = "reset HEAD --hard";
        };
        diff-so-fancy.enable = true;
        signing = {
          signByDefault = true;
          key = "/home/philip/.ssh/gitKey";
        };
        extraConfig = {
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
      cursors = {
        enable = true;
        accent = "peach";
      };
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

    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":menu,close";
      };
      "org/gnome/desktop/interface" = {
        accent-color = "pink";
        gtk-theme = "Adwaita";
        color-scheme = "prefer-light";
        font-name = "Manrope 13";
      };
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
