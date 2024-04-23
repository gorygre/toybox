main::IO()
main = do
  let unsorted = [3, 1, 2, 2, 2, 4]
  let ascending = [1, 2, 3, 4]
  putStrLn "Exercise #1"
  putStrLn $ show $ Main.elem 1 unsorted
  putStrLn "Exercise #2"
  putStrLn $ show $ Main.nub unsorted
  putStrLn "Exercise #3"
  putStrLn $ show $ Main.isAsc unsorted
  putStrLn $ show $ Main.isAsc ascending

elem :: (Eq a) => a -> [a] -> Bool
elem _ [] = False
elem a (x:xs) = (x == a) || (Main.elem a xs)

nub :: (Eq a) => [a] -> [a]
nub (a:as)
  | null as = [a]
  | Main.elem a as = nub as
  | otherwise = a : nub as

isAsc :: [Int] -> Bool
isAsc [] = True
isAsc (x:xs) = 
  if null xs then
    True
  else
    (x <= head xs) && isAsc xs
