{ pkgs, lib, ... }:

let
  runtimeInputs = with pkgs; [
    bash
    gawk
    curl
    logger
  ];
in
pkgs.stdenv.mkDerivation {
  pname = "portal-escape";
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
}
