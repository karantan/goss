{
# Allows CI to override this to an empty directory to determine dependencies
# Which then can get cached without the source code itself
buildSrc ? ./. }:
let

  pkgs = import (fetchTarball {
    # https://github.com/NixOS/nixpkgs/tree/nixos-20.03 on 2021-01-16
    # TODO: make sure this commit hash matches the one in ebn-nixos/nixos-configs/nixpkgs.nix
    url =
      "https://github.com/NixOS/nixpkgs/tarball/929768261a3ede470eafb58d5b819e1a848aa8bf";
    sha256 = "0zi54vbfi6i6i5hdd4v0l144y1c8rg6hq6818jjbbcnm182ygyfa";
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

  # no need to have a buildPhase because buildGoDir already calls go install.
  # see: https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/go-packages/generic/default.nix#L140-L205
  # buildPhase = ''
  #   ( cd go/src/${goPackagePath} && make build )
  # '';

  shellHook = ''
    export PATH="${lib.makeBinPath [ pkgs.vgo2nix ]}:$PATH"
  '';
}
