main::IO()
main = do
  -- function application
  putStrLn $ show $ in_range 4 5 3
  putStrLn $ show $ greater_than 1 2
  putStrLn $ show $ less_than 1 2
  putStrLn $ show $ positive 1

-- function type
in_range :: Integer -> Integer -> Integer -> Bool
-- function definition
in_range min max x = 
  x >= min && x <= max

-- type
foo :: Integer
foo = 3

greater_than x y = 
-- let/in
  let z = y
  in
    x > z

less_than x y = x < z
-- where binding
  where
    z = y

positive x =
-- if/else
  if x >= 0 then True else False
