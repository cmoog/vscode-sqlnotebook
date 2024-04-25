{ runCommand, nodejs, zip, unzip, sqls, buildNodeModules, stdenv, python3, pkg-config, libsecret }:
stdenv.mkDerivation {
  name = "vscode-sql-notebook.vsix";
  src = runCommand "src-with-sqls" { } ''
    mkdir $out
    cp -r ${./.}/* $out
    cp -r ${sqls}/bin $out/sqls_bin
  '';
  nativeBuildInputs = [
    buildNodeModules.hooks.npmConfigHook
    libsecret
    nodejs
    pkg-config
    python3
    unzip
    zip
  ];
  nodeModules = buildNodeModules.fetchNodeModules {
    packageRoot = ./.;
  };
  buildPhase = ''
    npm run build
  '';
  installPhase = ''
    # vsce errors when modtime of zipped files are > present
    new_modtime="0101120000" # MMDDhhmmYY (just needs to be fixed and < present)
    mkdir ./tmp
    unzip -q ./*.vsix -d ./tmp

    for file in $(find ./tmp/ -type f); do
      touch -m "$new_modtime" "$file"
      touch -t "$new_modtime" "$file"
    done

    cd ./tmp
    zip --quiet --recurse-paths $out .
  '';
}
