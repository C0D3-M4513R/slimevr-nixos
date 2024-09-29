 { 
stdenvNoCC
, lib
, fetchurl
, makeWrapper
, writeShellScriptBin
, jdk
#, eudev
#, hidapi
, steam-run
}:

stdenvNoCC.mkDerivation rec {
  pname = "slimevr-server-server";
  version = "0.13.0";

  src = fetchurl {
    url = "https://github.com/SlimeVR/SlimeVR-Server/releases/download/v${version}/slimevr.jar";
    hash = "sha256-Sj39D/QAR/lwojxsRcpe0k/21HC6R9mHPrj+H6s+qZA=";
  };

  executable = writeShellScriptBin "slimevr-server" "${steam-run}/bin/steam-run ${jdk}/bin/java -jar ${src} $@";
#'-Djava.library.path=${hidapi.out}/lib;${eudev.out}/lib' 

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${executable}/bin/slimevr-server $out/bin/
  '';


  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = " Server app for SlimeVR ecosystem";
    platforms = platforms.linux;
  };
}
