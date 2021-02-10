{-# LANGUAGE TypeApplications #-}
module Cut.Church
( tests
) where

import Control.Carrier.Cut.Church
import Control.Effect.Reader
import Hedgehog
import Test.Tasty
import Test.Tasty.Hedgehog

tests :: TestTree
tests = testGroup "Cut.Church"
  [ testProperty "cutfail operates through higher-order effects" . property $
    runCutA @[] (local (id @()) cutfail <|> pure 'a') ()
    ===
    runCutA @[] (cutfail <|> pure 'a') ()
  ]
