 { stdenv, lib
, fetchurl
, fetchFromGitHub
, autoPatchelfHook
, pkg-config
, cmake
, gnumake
, vcpkg
, protobuf
, simdjson
, openvr
}:

stdenv.mkDerivation rec {
  pname = "slimevr-openvr-driver";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-OpenVR-Driver";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-XyzJWmlcCZzymw+7wrmQNSrssY9BxDY5lygnZHGAh1o=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    vcpkg
    gnumake
    autoPatchelfHook
  ];

  buildInputs = [
     openvr
     protobuf
     simdjson
  ];

  env = {
    VCPKG_ROOT = "${vcpkg}/share/vcpkg";
  };

  cmakeFlags = [
    "-DVCPKG_MANIFEST_INSTALL=OFF"
    "-DOPENVR_LIB=${openvr}/lib"
    "-DVCPKG_PATH=${vcpkg}/bin/vcpkg"
  ];

  installPhase = ''
    runHook preInstall
    cp -r driver/slimevr $out/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = "SlimeVR driver for OpenVR";
    platforms = platforms.linux;
  };
}
