module Main where

import System (getArgs)
import System.IO (readFile)
import List (nubBy)
import Data.List (intercalate)

splitOn :: (a -> Bool) -> [a] -> [[a]]
splitOn _ [] = []
splitOn f l@(x:xs)
  | f x = splitOn f xs
  | otherwise = let (h,t) = break f l in h:(splitOn f t)

cleanWhiteSpace str = reverse $ dropWhile (==' ') $ reverse $ dropWhile (==' ') str

main = do
  fn:_ <- getArgs
  cnts <- readFile fn
  let lines = map (splitOn (=='\t')) $ splitOn (=='\n') cnts
  let clean_lines = nubBy (\x y -> (x !! 3) == (y !! 3)) $ (map.map) cleanWhiteSpace lines
  putStr (intercalate "\n" (map (intercalate "\t") clean_lines))
