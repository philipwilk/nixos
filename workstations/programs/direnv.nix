{ ... }:
{
  programs = {
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
  };
}
