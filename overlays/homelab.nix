{
  ...
}:
{
  nixpkgs.overlays = [
    # add cpu monitoring option
    (import ./hddfancontrol)

    (final: prev: {
      python312 = prev.python312.override {
        packageOverrides = pFinal: pPrev: {
          mlxtend = prev.python312.pkgs.callPackage ./mlxtend { };
          imbalanced-learn = prev.python312.pkgs.callPackage ./imbalanced-learn { };
        };
      };
      python313 = prev.python313.override {
        packageOverrides = pFinal: pPrev: {
          mlxtend = prev.python313.pkgs.callPackage ./mlxtend { };
          jupyterlab-git = prev.python313.pkgs.callPackage ./jupyterlab-git { };
          imbalanced-learn = prev.python312.pkgs.callPackage ./imbalanced-learn { };
        };
      };
    })

    (final: prev: {
      proj = prev.proj.overrideAttrs {
        version = "9.7.1";
        src = prev.fetchFromGitHub {
          owner = "OSGeo";
          repo = "PROJ";
          tag = "9.7.1";
          hash = "sha256-xXtqbLPS2Hu9gC06b72HDjnNRh4m0ism97hP8FFYOMo=";
        };
      };
    })

    (import ./searxng)

    (final: prev: {
      openthread-border-router = prev.callPackage ./openthread-border-router { };
    })
  ];
}
