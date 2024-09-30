 { 
stdenv
, lib
, fetchFromGitHub
, fetchurl
, autoPatchelfHook
, makeBinaryWrapper
, patchelf
, gradle

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
  pname = "slimevr-server-gui";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-Server";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-Q2N+oYQ1VgJ+XyBRhCPY4YVSNP6kiZ6ErPHS13XeVrE=";
   # populate values that require us to use git. By doing this in postFetch we
   # can delete .git afterwards and maintain better reproducibility of the src.
   leaveDotGit = true;
    postFetch = ''
      cd "$out"
      HASH=$(git rev-parse --verify --short HEAD)
      substituteInPlace $out/gui/vite.config.ts \
        --replace-fail "execSync('git rev-parse --verify --short HEAD')" "\"$HEAD\"" \
        --replace-fail "const versionTag = execSync('git --no-pager tag --sort -taggerdate --points-at HEAD')
  .toString()
  .split('\n')[0]
  .trim();
" "const versionTag = \"v${version}\";" \
       --replace-fail "const gitClean = execSync('git status --porcelain').toString() ? false : true;" "const gitClean = true"

      substituteInPlace $out/gui/src-tauri/src/util.rs \
        --replace-fail "const VERSION: &str = if build::TAG.is_empty() {
	build::SHORT_COMMIT
} else {
	build::TAG
};" "const VERSION: &str = \"v${version}\";" \
        --replace-fail 'const MODIFIED: &str = if build::GIT_CLEAN { "" } else { "-dirty" };' 'const MODIFIED: &str = "";' 

      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  cargoHash = "sha256-VYBoCvsMeGazrnbKvFg4fXRGhMueqhK/vPLMv+aIHe0=";

  jar = fetchurl {
    url = "https://github.com/SlimeVR/SlimeVR-Server/releases/download/v${version}/slimevr.jar";
    hash = "sha256-Sj39D/QAR/lwojxsRcpe0k/21HC6R9mHPrj+H6s+qZA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
#required things for building
    cargo
    rustc
    husky
    pkg-config
    makeBinaryWrapper
    autoPatchelfHook
  ];

  buildInputs= [
    glib
    gtk3.dev
    webkitgtk_4_1.dev

    gobject-introspection
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-L5ndNzESKddcQCLugmSQyvWr6QVKrMmR1qiclYPzhto";
  };

  preBuild = ''
    pnpm i
    pushd gui
    pnpm run build
    popd
  '';

  preInstall = ''
    mkdir -p $out/jar
    cp ${jar} $out/jar/slimevr.jar
    mkdir -p $out/share/applications
    mkdir -p $out/icon
    cp ${src}/gui/src-tauri/icons/icon.svg $out/icon
    cp ${src}/gui/src-tauri/dev.slimevr.SlimeVR.desktop $out/share/applications/
    sed -i $out/share/applications/dev.slimevr.SlimeVR.desktop -e "s|{{exec}}|$out/bin/slimevr|" -e "s|{{icon}}|$out/icon/icon.svg|"
    #FIXME: Without this, the slime gui just complains, that it doesn't have a valid java install.
    sed -i $out/share/applications/dev.slimevr.SlimeVR.desktop -e "s|Terminal=false|Terminal=true|"
  '';

  runtimeDependencies = [
      libayatana-appindicator
  ];

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
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"

  '';

  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = " Server app for SlimeVR ecosystem";
    platforms = platforms.linux;
  };
}
