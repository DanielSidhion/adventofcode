{
  description = "AoC2023";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    nil.url = "github:oxalica/nil";
  };

  outputs = { self, nixpkgs, flake-utils, nil, ... }:
    (flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                git
                nixpkgs-fmt
                nil.packages.${system}.default
                zig
                zls
              ];
            };
          };

          packages = { };
          apps = { };
        }
      )
    );
}
