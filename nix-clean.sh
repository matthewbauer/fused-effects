#!/bin/sh

if [ -d dist-newstyle/build/*/*/*/build/.ghc-nix ]; then
  find dist-newstyle/build/*/*/*/build/.ghc-nix -type l -exec sh -c 'path=$(readlink $1); rm $1; nix --experimental-features nix-command store delete $path' sh {} \;
fi
