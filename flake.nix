{
  description = "A NetworkManager dispatcher script to automatically dismiss captive portals.";

  inputs = {
    nixpkgs.url = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage ./derivation.nix { };
      }
    );
}
