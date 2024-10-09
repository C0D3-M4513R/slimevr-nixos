{pkgs, ...}:
{
  slimevr_feeder = pkgs.callPackage ./slimevr_feeder.nix {};
  slimevr_openvr_driver = pkgs.callPackage ./slimevr_openvr_driver.nix {};
  slimevr-server-gui = pkgs.callPackage ./slimevr-server-gui {};
}
