{
  description = "Modules for SlimeVR on NixOs";

  inputs = {
#    flake-parts.url = "github:hercules-ci/flake-parts";
#    utils.url = "github:numtide/flake-utils";
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = true;
    };
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#    treefmt-nix.url = "github:numtide/treefmt-nix";
#    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ ... }:
    {
      nixosModules = {
          packages = import ./packages.nix;
          default = packages;
      };
    };
}
