(final: prev: {
  chip-ota-provider-app = prev.callPackage (
    {
      stdenv,
      fetchurl,
      autoPatchelfHook,
      libnl,
    }:
    let
      srcInfo =
        {
          x86_64-linux = {
            filename = "chip-ota-provider-app-x86-64";
            hash = "sha256-RVDfevZSnkYgRj0cASf4MOwkBMgXrUxjQ7KeMs7AFE4=";
          };
          aarch64-linux = {
            filename = "chip-ota-provider-app-aarch64";
            hash = "sha256-4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
          };
        }
        .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "chip-ota-provider-app";
      version = "2025.9.0";

      src = fetchurl {
        url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/${finalAttrs.version}/${srcInfo.filename}";
        hash = srcInfo.hash;
      };

      dontUnpack = true;
      dontBuild = true;

      nativeBuildInputs = [ autoPatchelfHook ];

      buildInputs = [
        libnl
        stdenv.cc.cc.lib
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 $src $out/bin/chip-ota-provider-app

        runHook postInstall
      '';
    })
  ) { };
})
