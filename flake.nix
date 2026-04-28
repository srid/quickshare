{
  description = "quickshare — share .html files via Cloudflare R2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = { config, pkgs, ... }: {
        packages.default = pkgs.writeShellApplication {
          name = "quickshare";
          runtimeInputs = [ pkgs.wrangler pkgs.coreutils ];
          text = builtins.readFile ./quickshare.sh;
        };
        apps.default.program = "${config.packages.default}/bin/quickshare";
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.wrangler ];
        };
      };
    };
}
