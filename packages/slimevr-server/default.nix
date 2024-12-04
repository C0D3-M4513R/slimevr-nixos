 { 
stdenv
, lib
, fetchFromGitHub
, fetchurl
, fetchzip

, autoPatchelfHook
, makeBinaryWrapper
, wrapGAppsHook

, pkg-config

, nodejs
, pnpm
, cargo
, rustc
, husky
, rustPlatform

, glib
, gtk3
, webkitgtk_4_1

, jdk
#slime-server libs
, eudev
, libusb1
#rpath libs of gui
, libayatana-appindicator
, gst_all_1
, gobject-introspection
}:

rustPlatform.buildRustPackage rec {
  pname = "slimevr-server";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-Server";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-XQDbP+LO/brpl7viSxuV3H4ALN0yIkj9lwr5eS1txNs";
  };

  cargoHash = "sha256-hCI0IQpGgSO7dXdz3gXXBGStOTlZNIXdkPhq1wiUxFo=";

  jar = fetchurl {
    url = "https://github.com/SlimeVR/SlimeVR-Server/releases/download/v${version}/slimevr.jar";
    hash = "sha256-s6uznJtsa1bQAM1QIdBMey+m9Q/v2OfKQPXjD5RAR78=";
  };

  guiHtml = fetchzip {
    url = "https://github.com/SlimeVR/SlimeVR-Server/releases/download/v${version}/slimevr-gui-dist.tar.gz";
    stripRoot = false;
    hash = "sha256-u1EtSG1uTGIyROo5TznzQ+Z8g6WAiU0SmDObm/w1f9k=";
  };

  nativeBuildInputs = [
#required things for building
    cargo
    rustc
    pkg-config
    makeBinaryWrapper
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs= [
    glib
    gtk3.dev
    webkitgtk_4_1.dev
  ];

  preBuild = ''
    pushd gui
    cp -r ${guiHtml} dist
    popd
  '';

  preInstall = ''
    install -Dm644 ${jar} $out/share/slimevr/slimevr.jar
    install -Dm644 ${src}/gui/src-tauri/icons/icon.svg $out/share/icons/hicolor/scalable/apps/slimevr.svg
    install -Dm644 ${src}/gui/src-tauri/dev.slimevr.SlimeVR.desktop $out/share/applications/dev.slimevr.SlimeVR.desktop
    sed -i $out/share/applications/dev.slimevr.SlimeVR.desktop -e "s|{{exec}}|$out/bin/slimevr|" -e "s|{{icon}}|slimevr|"
  '';

  runtimeDependencies = [
      libayatana-appindicator
  ];

  dontWrapGApps = true;

  postFixup = let 
    libraryPath = lib.makeLibraryPath [
      eudev
      libusb1
    ];
  in ''
    #JAVA_HOME needs to be set for the gui to be able to launch the slime server. 
    #Same for the --add-flags.
    #The LD_LIBRARY_PATH is needed for the slime server to not crash when loading bundled hdapi libraries.
    #We can't modify them right now, because the jar is signed.
    #GST_PLUGIN_SYSTEM_PATH_1_0 is needed to hopefully fix the GStreamer plugins not being recognised.
    wrapProgram $out/bin/slimevr \
      --set-default JAVA_HOME "${jdk.home}" \
      --prefix LD_LIBRARY_PATH : ${libraryPath} \
      --add-flags "--launch-from-path $out/jar" \
      ''${gappsWrapperArgs[@]}
  '';

  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = " Server app for SlimeVR ecosystem";
    platforms = platforms.linux;
  };
}
