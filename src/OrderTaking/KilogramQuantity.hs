module OrderTaking.KilogramQuantity (
  KilogramQuantity
  , createKilogramQuantity
  ) where

data KilogramQuantity = KilogramQuantity Int
                    deriving Show

createKilogramQuantity :: Int -> Either String KilogramQuantity
createKilogramQuantity
  q | q < 0 = Left "KilogramQuantity can not be negative"
    | q > 1000 = Left "KilogramQuantity can not be more than 1000"
    | otherwise = Right $ KilogramQuantity q
