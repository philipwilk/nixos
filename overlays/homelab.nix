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
        };
      };
      python313 = prev.python313.override {
        packageOverrides = pFinal: pPrev: {
          mlxtend = prev.python313.pkgs.callPackage ./mlxtend { };
        };
      };
    })
  ];
}
