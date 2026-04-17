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

    (import ./searxng)
  ];
}
