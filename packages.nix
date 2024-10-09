{pkgs, ...}:
{
  slimevr_feeder = pkgs.callPackage ./packages/slimevr_feeder.nix {};
  slimevr_openvr_driver = pkgs.callPackage ./packages/slimevr_openvr_driver.nix {};
  slimevr-server-gui = pkgs.callPackage ./packages/slimevr-server-gui {};
}
