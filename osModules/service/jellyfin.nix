{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.services.jellyfin.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the jellyfin server.
    '';
  };
  config = lib.mkIf config.homelab.services.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      dataDir = "${config.homelab.stateDir}/jellyfin";
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.graphics = {
      # hardware.opengl in 24.05
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver # previously vaapiIntel
        libva-vdpau-driver
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        vpl-gpu-rt # QSV on 11th gen or newer
      ];
    };

    nixpkgs.overlays = with pkgs; [
      (final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (
          finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall

              # this is the important line
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web

              runHook postInstall
            '';
          }
        );
      })
    ];

    services.nginx.virtualHosts."jelly.${config.homelab.tld}".locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };

    networking.domains.subDomains."jelly.${config.homelab.tld}" = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
