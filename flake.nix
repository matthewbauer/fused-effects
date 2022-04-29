{
  description = "A fast, flexible, fused effect system.";
  inputs = {
    ghc-nix = {
      url = "github:matthewbauer/ghc-nix";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, ghc-nix }: let
    systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    nixpkgsFor = forAllSystems (system: import nixpkgs { overlays = [self.overlays.default]; inherit system; });
    compiler = "ghc922";
  in {
    overlays.default = final: prev: {
      haskellPackages = prev.haskell.packages.${compiler}.override {
        overrides = hfinal: hprev: {
          ghc-nix = hfinal.callCabal2nix "ghc-nix" "${ghc-nix}/ghc-nix" {};
          fused-effects' = hfinal.callCabal2nix "fused-effects" self {};
        };
      };
    };
    packages = forAllSystems (system: {
      fused-effects = nixpkgsFor.${system}.haskellPackages.fused-effects';
      default = self.packages.${system}.fused-effects;
    });
    devShells = forAllSystems (system: {
      fused-effects = self.packages.${system}.fused-effects.env.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [
          nixpkgsFor.${system}.haskellPackages.cabal-install
          nixpkgsFor.${system}.haskellPackages.ghc-nix
          nixpkgsFor.${system}.hyperfine
        ];
      });
      default = self.devShells.${system}.fused-effects;
    });
  };
}
