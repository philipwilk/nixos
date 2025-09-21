(final: prev: {
  octodns = prev.octodns.overrideAttrs (
    finalAttrs: previousAttrs: {
      passthru = previousAttrs.passthru // {
        providers = previousAttrs.passthru.providers // {
          desec = prev.python3Packages.callPackage (
            {
              lib,
              buildPythonPackage,
              fetchFromGitHub,
              octodns,
              pytestCheckHook,
              pythonOlder,
              requests,
              requests-mock,
              setuptools,
            }:

            buildPythonPackage rec {
              pname = "octodns-desec";
              version = "1.0.0";
              pyproject = true;

              disabled = pythonOlder "3.10";

              src = fetchFromGitHub {
                owner = "rootshell-labs";
                repo = "octodns-desec";
                tag = version;
                hash = "sha256-0mrPyZSWfb82ZOCVDNI4QtgJerbn7fWiBQYfG2VD2j4=";
              };

              build-system = [
                setuptools
              ];

              dependencies = [
                octodns
                requests
              ];

              env.OCTODNS_RELEASE = 1;

              pythonImportsCheck = [ "octodns_desec" ];

              nativeCheckInputs = [
                pytestCheckHook
                requests-mock
              ];

              meta = {
                description = "deSEC DNS provider for octoDNS";
                homepage = "https://github.com/rootshell-labs/octodns-desec";
                changelog = "https://github.com/rootshell-labs/octodns-desec/blob/${src.tag}/CHANGELOG.md";
                license = lib.licenses.mit;
                maintainers = [ ]; # TODO
              };
            }
          ) { };
        };
      };
    }
  );
})
