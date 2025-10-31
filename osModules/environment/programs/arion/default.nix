{
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    # directly stolen from https://github.com/hercules-ci/arion/issues/48#issuecomment-1768406041
    (self: super: {
      docker-compose-compat = (
        self.runCommand "podman-compose-docker-compat" { } ''
          mkdir -p $out/bin
          ln -s ${self.podman-compose}/bin/podman-compose $out/bin/docker-compose
        ''
      );

      #the arion nixpkgs expression embeds a reference to docker-compose_1 and uses it via PATH
      arion = (
        super.arion.overrideAttrs (o: {
          postInstall = ''
            mkdir -p $out/libexec
            mv $out/bin/arion $out/libexec
            makeWrapper $out/libexec/arion $out/bin/arion \
              --unset PYTHONPATH \
              --prefix PATH : ${self.lib.makeBinPath [ self.docker-compose-compat ]} \
              ;
          '';
        })
      );
    })
  ];

  environment.systemPackages = with pkgs; [
    arion
  ];
}
