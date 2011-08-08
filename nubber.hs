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
  colstr:fn:_ <- getArgs
  cnts <- readFile fn
  let lines = map (splitOn (=='\t')) $ splitOn (=='\n') cnts
  let col = read colstr
  let clean_lines = nubBy (\x y -> (x !! col) == (y !! col)) $ (map.map) cleanWhiteSpace lines
  putStr (intercalate "\n" (map (intercalate "\t") clean_lines))
