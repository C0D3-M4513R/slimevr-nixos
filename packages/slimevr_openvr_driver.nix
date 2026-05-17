{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, vcpkg
, protobuf
, simdjson
, openvr
, libuv
, catch2_3
, uvw
}:

stdenv.mkDerivation rec {
  pname = "slimevr-openvr-driver";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-OpenVR-Driver";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-nSxuhq5XSFx/vmZbvVXT8Zh7Hq6kpXv86poep8gwfVM=";
  };

  nativeBuildInputs = [
    pkg-config
    vcpkg
    cmake
  ];
  buildInputs = [
    openvr
    protobuf
    simdjson
    libuv
    uvw
    catch2_3
  ];

  cmakeFlags = [
    "-DVCPKG_MANIFEST_INSTALL=OFF"
    "-DOPENVR_LIB=${openvr}/lib/libopenvr_api.so"
    "-DOPENVR_INCLUDE_DIR=${openvr}/include/openvr"
  ];

  env = {
    VCPKG_ROOT = "${vcpkg}/share/vcpkg";
  };

  postPatch = ''
    # Fix protobuf
    substituteInPlace src/VRDriver.cpp test/TestBridgeClientMock.cpp test/common/TestBridgeClient.cpp src/bridge/BridgeClient.cpp \
      --replace-fail 'CreateMessage<messages::' 'Create<messages::'

    #Use Nix OpenVr
    rm -rf libraries/openvr
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(OPENVR_INCLUDE_DIR "''${CMAKE_CURRENT_SOURCE_DIR}/libraries/openvr/headers")' ' '

    #Fix tests not linking uv
    substituteInPlace CMakeLists.txt \
      --replace-fail 'Catch2::Catch2WithMain'  'Catch2::Catch2WithMain uv'
  '';

  installPhase = ''
  runHook preInstall
    mkdir -p $out
    rm -rf $out/*
    install -Dm 755 libSlimeVR-OpenVR-Driver.so $out/libSlimeVR-OpenVR-Driver.so

    cp -r driver $out/
    cp -r $src/driver/* $out/driver
    unlink $out/driver/slimevr/bin/win64/.gitkeep
    rm -d $out/driver/slimevr/bin/win64 || true

    runHook postInstall
  '';

}
