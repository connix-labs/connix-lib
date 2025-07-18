{
  description = "Nix development environment with language server and formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Nix language server
            nixd
            # Nix code formatter
            alejandra
            # Tree formatter
            treefmtEval.config.build.wrapper
          ];

          shellHook = ''
            echo "🔧 Nix development environment ready"
            echo "  • nixd: Nix language server"
            echo "  • alejandra: Nix formatter"
            echo "  • treefmt: Multi-language formatter"
          '';
        };

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}
