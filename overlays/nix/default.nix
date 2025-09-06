(final: prev: {
  nixVersions = prev.nixVersions.extend (
    finalNixV: prevNixV: {
      nixComponents_2_30 = (
        prevNixV.nixComponents_2_30.overrideScope (
          finalScope: prevScope: {
            aws-sdk-cpp = null;
            withAWS = false;
            patches = [
              ./0001-bugfix-3514-build-fails-when-cache-offline.patch
              ./0002-feat-13301-fallback-from-failing-substituters-treat-.patch
            ];
          }
        )
      );
    }
  );
})
