(final: prev: {
  searxng = prev.searxng.overrideAttrs {
    version = "0-unstable-2026-04-13";

    src = prev.fetchFromGitHub {
      owner = "searxng";
      repo = "searxng";
      rev = "ee66b070a9505ae57dbbb49330f004f339743ed8";
      hash = "sha256-Qo73UP5HxzH3E4kGfpZD/J3GaNcqrx1RIk2a6V2Tg00=";
    };
  };
})
