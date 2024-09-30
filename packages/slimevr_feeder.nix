 { stdenv, lib
, fetchurl
, fetchFromGitHub
, autoPatchelfHook
, patchelf
, pkg-config
, cmake
, gnumake
, vcpkg
, protobuf
, simdjson
, openvr
, fmt
, libargs

}:

stdenv.mkDerivation rec {
  pname = "slimevr-feeder";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-Feeder-App";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-b4W8TqD+mp/ySrHFtx2MCIyysm6bO/L/qrf37e8SiOM=";
    postFetch = ''
      substituteInPlace $out/cmake/gitversion.cmake \
        --replace-fail 'set(_build_version "unknown")' 'set(_build_version "v${version}")'
    '';
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    vcpkg
    gnumake
    autoPatchelfHook
    patchelf
  ];

  buildInputs = [
     openvr
     protobuf
     simdjson
     fmt
     libargs
  ];

  cmakeFlags = [
    "-DVCPKG_MANIFEST_INSTALL=OFF"
  ];

  preConfigure = ''
    mkdir -p include
    #FIXME: is there a cleaner way?
    cp ${openvr}/include/openvr/* include/
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 SlimeVR-Feeder-App $out/SlimeVR-Feeder-App
    mkdir -p $out/bindings
    cp -r ../bindings $out/bindings
    install -Dm644 ../manifest.vrmanifest $out/manifest.vrmanifest
    runHook postInstall
  '';

#  preFixup = ''
#    patchelf --add-needed libopenvr_api.so $out/bin/SlimeVR-Feeder-App
#  '';

  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = "WIP OpenVR Application that gets the position of everything to feed to SlimeVR-Server. In theory. ";
    platforms = platforms.linux;
  };
}
