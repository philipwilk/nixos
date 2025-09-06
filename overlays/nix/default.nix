(final: prev: {
  nixVersions = prev.nixVersions.extend (
    finalNixV: prevNixV: {
      nixComponents_2_30 = (
        prevNixV.nixComponents_2_30.overrideScope (
          finalScope: prevScope: {
            aws-sdk-cpp = null;
            withAWS = false;
            patches = [ ./0001-libstore-allow-http-binary-cache-store-to-soft-error.patch ];
          }
        )
      );
    }
  );
})
