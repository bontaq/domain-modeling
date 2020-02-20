module OrderTaking.OrderId where

data OrderId = OrderId String
               deriving Show

create :: String -> Either String OrderId
create str
  | length str == 0 = Left "OrderId must not be null or empty"
  | length str > 50 = Left "OrderId must not be more than 50 chars"
  | otherwise = Right $ OrderId str

value :: OrderId -> String
value (OrderId str) = str
