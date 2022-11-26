{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";
  };

  outputs = { self, nixpkgs, utils, naersk, nixpkgs-mozilla }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system;

        };
        toolchain = (pkgs.rustChannelOf {
          rustToolchain = ./rust-toolchain;
          sha256 = "";
          #        ^ After you run `nix-build`, replace this with the actual
          #          hash from the error message
        }).rust;
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo rustc rustfmt pre-commit rustPackages.clippy gcc libudev-zero alsa-lib pkg-config ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      });
}
