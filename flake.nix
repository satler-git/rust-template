{
  description = "A full Rust flake";

  inputs = {
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      rust-overlay,
      pre-commit-hooks,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      checks.${system} = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            clippy.enable = true;
            cargo-check.enable = true;
          };
        };
        formatting = treefmtEval.config.build.check self;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          rust-bin.stable.latest.default
        ];
      };

      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "rust-template";
        version = "0.1.0";

        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
      };

      formatter.${system} = treefmtEval.config.build.wrapper;
    };
}
