 { 
stdenv
, lib
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, gradle
, jdk

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
}:

rustPlatform.buildRustPackage rec {
  pname = "slimevr-server-gui";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "SlimeVR";
    repo = "SlimeVR-Server";
    fetchSubmodules = true;
    rev = "v" + version;
    hash = "sha256-QGbhMUHrdI/+l6W1x+PIUP6Qz8/pfqjZJHtZcXv+8ZI=";
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

      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  cargoHash = "sha256-VYBoCvsMeGazrnbKvFg4fXRGhMueqhK/vPLMv+aIHe0=";
 
  nativeBuildInputs = [
    nodejs
    pnpm.configHook
#required things for building
    cargo
    rustc
    husky
    pkg-config
    makeWrapper
  ];

  buildInputs= [
    glib
    gtk3.dev
    webkitgtk_4_1.dev
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

  meta = with lib; {
    homepage = "https://slimevr.dev";
    description = " Server app for SlimeVR ecosystem";
    platforms = platforms.linux;
  };
}
