{
  buildNpmPackage,
  nodejs_24,
  lib,
}:
buildNpmPackage {
  pname = "personal-pi-extensions";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./package.json
      ./package-lock.json
      ./tsconfig.json
      ./src
    ];
  };
  nodejs = nodejs_24;
  npmDepsHash = "sha256-Oh83g8VdW6KN4XjOqyODYw4JKLykxSU5jLF2hy21Hxo=";
  npmInstallFlags = ["--ignore-scripts"];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    npm run check
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/pi-extensions
    cp dist/*.js $out/share/pi-extensions/
    runHook postInstall
  '';
}
