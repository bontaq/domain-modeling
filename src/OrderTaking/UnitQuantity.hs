module OrderTaking.UnitQuantity (
  UnitQuantity
  , createUnitQuantity
  ) where

data UnitQuantity = UnitQuantity Int
                    deriving Show

createUnitQuantity :: Int -> Either String UnitQuantity
createUnitQuantity
  q | q < 0 = Left "UnitQuantity can not be negative"
    | q > 1000 = Left "UnitQuanitity can not be more than 1000"
    | otherwise = Right $ UnitQuantity q
