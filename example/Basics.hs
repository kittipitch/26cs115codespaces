module Basics (sumtorial) where
import Test.HUnit

sumtorial :: Int -> Int
sumtorial 0 = 0
sumtorial n = n + sumtorial (n - 1)

main :: IO ()
main = runTestTTAndExit $ TestList
  [ "sumtorial 0" ~: sumtorial 0 ~?= 0
  , "sumtorial 3" ~: sumtorial 3 ~?= 6
  ]
