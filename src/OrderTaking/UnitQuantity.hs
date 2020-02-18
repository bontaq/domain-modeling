module OrderTaking.UnitQuantity (
  UnitQuantity
  , unitQuantity
  ) where

data UnitQuantity = UnitQuantity Int
                    deriving Show

unitQuantity :: Int -> Either String UnitQuantity
unitQuantity q | q < 0 = Left "UnitQuantity can not be negative"
               | q > 1000 = Left "UnitQuanitity can not be more than 1000"
               | otherwise = Right $ UnitQuantity q
