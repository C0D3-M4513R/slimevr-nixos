{
  description = "Modules for SlimeVR on NixOs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = true;
    };
  };

  outputs =
    inputs@{ ... }:
    {
      nixosModules = rec {
          packages = import ./packages.nix;
          default = packages;
      };
    };
}
