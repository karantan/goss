{
# Allows CI to override this to an empty directory to determine dependencies
# Which then can get cached without the source code itself
buildSrc ? ./. }:
let

  pkgs = import (fetchTarball {
    # Latest nixpkgs-unstable from https://status.nixos.org/
    # Stable doesn't seem to have some Go changes that we need
    url =
      "https://github.com/NixOS/nixpkgs/tarball/0ce8cf87d8402fc7e4677ea3a2138a7673f0756e";
    sha256 = "1wc2b1sjq6iyr24l7wf6raja16qfqssam1hakkwwn755iz17ppj5";
  }) {
    config = { };
    overlays = [ ];
  };
  inherit (pkgs) lib;

  inherit (import (fetchTarball {
    url =
      "https://github.com/hercules-ci/gitignore.nix/tarball/7415c4feb127845553943a3856cbc5cb967ee5e0";
    sha256 = "1zd1ylgkndbb5szji32ivfhwh04mr1sbgrnvbrqpmfb67g2g3r9i";
  }) { inherit lib; })
    gitignoreSource;

in pkgs.buildGo114Package rec {
  pname = "goss";
  version = "0.3.13";
  src = gitignoreSource buildSrc;
  goPackagePath = "goss";

  # So the version is embedded in the binary
  VERSION = version;

  goDeps = ./deps.nix;

  nativeBuildInputs = [ pkgs.git ];

  buildPhase = ''
    ( cd go/src/${goPackagePath} && make install )
  '';

  shellHook = ''
    export PATH="${lib.makeBinPath [ pkgs.vgo2nix ]}:$PATH"
  '';
}
