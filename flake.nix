{
  description = "Modules for SlimeVR on NixOs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = true;
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { utils, nixpkgs,... }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          slimevr_feeder = pkgs.callPackage packages/slimevr_feeder.nix {};
          uvw = pkgs.callPackage packages/uvw.nix {};
          slimevr_openvr_driver = pkgs.callPackage packages/slimevr_openvr_driver.nix { inherit uvw; };
        };
    });
}
