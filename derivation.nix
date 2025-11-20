{ pkgs, stdenv, lib }:

let
  runtimeInputs = with pkgs; [
    bash
    gawk
    curl
    logger
  ];
in
stdenv.mkDerivation {
  name = "portal-escape";
  src = ./.;
  buildInputs = runtimeInputs;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp portal-escape.sh $out/bin/portal-escape
    wrapProgram $out/bin/portal-escape \
      --prefix PATH : ${lib.makeBinPath runtimeInputs}
  '';

  meta = {
    description = "A NetworkManager dispatcher script to automatically dismiss captive portals.";
    homepage = https://github.com/Computerdores/portal-escape;
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platform = lib.platforms.all;
    mainProgram = "portal-escape";
  };
}
