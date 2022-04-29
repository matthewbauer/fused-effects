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
          ghc-nix = hprev.callCabal2nix "ghc-nix" "${ghc-nix}/ghc-nix" {};
          fused-effects = hprev.callCabal2nix "fused-effects" self {};
        };
      };
    };
    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}.haskellPackages) fused-effects ghc-nix;
      default = self.packages.${system}.fused-effects;
    });
    devShells = forAllSystems (system: {
      fused-effects = self.packages.${system}.fused-effects.env.overrideAttrs (old: {
        buildInputs = old.nativeBuildInputs ++ (with nixpkgsFor.${system}.haskellPackages; [cabal-install ghc-nix]);
        nativeBuildInputs = old.nativeBuildInputs
          ++ (with nixpkgsFor.${system}.haskellPackages; [cabal-install ghc-nix])
          ++ (with nixpkgsFor.${system}; [hyperfine]);
      });
      default = self.devShells.${system}.fused-effects;
    });
  };
}
