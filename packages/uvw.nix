{ stdenv
, lib
, fetchurl
, fetchFromGitHub
, autoPatchelfHook
, pkg-config
, cmake
, gnumake
, vcpkg
, libuv
}:

stdenv.mkDerivation rec {
  pname = "uvw";
  version = "3.4.0_libuv_v1.48";

  src = fetchFromGitHub {
    owner = "skypjack";
    repo = "uvw";
    rev = "v" + version;
    hash = "sha256-Bm10URXVnBoB9WAMoa4fToUs/iF8iLc91iSKJtw+1+8=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    vcpkg
    gnumake
    autoPatchelfHook
  ];

  buildInputs = [
     libuv.dev
  ];

  meta = with lib; {
    description = "Header-only, event based, tiny and easy to use libuv wrapper in modern C++ - now available as also shared/static library!";
  };
}
