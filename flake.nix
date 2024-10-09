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

  outputs = { utils, ... }:
    utils.lib.eachDefaultSystem (system: {
      packages = rec {
          packages = import ./packages.nix;
          default = packages;
      };
    });
}
