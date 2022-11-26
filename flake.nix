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
        pkgs = import nixpkgs {
          overlays = [
            nixpkgs-mozilla.overlay
          ];
          inherit system;
        };
        # pkgs.latest.rustChannels.nightly.rust
        toolchain = (pkgs.rustChannelOf {
          rustToolchain = ./rust-toolchain;
          sha256 = "sha256-s6XVvROGjTKvbWQ/zjM3hPv15CcF4Uj9lDI5RfxZsnA=";
          #        ^ After you run `nix-build`, replace this with the actual
          #          hash from the error message
        }).rust;
        naersk-lib = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };
      in
      {
        defaultPackage = with pkgs; naersk-lib.buildPackage {
          buildInputs = [ libudev-zero alsa-lib pkg-config ];
          src = ./.;
        };
        devShell = with pkgs; mkShell {
          buildInputs = [ toolchain cargo rustc rustfmt pre-commit rustPackages.clippy gcc libudev-zero alsa-lib pkg-config ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      });
}
