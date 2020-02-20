module OrderTaking.TypeClasses where

--
-- This is a silly idea, ignore it
--

type Error = String

class SafeConstructor f where
  create :: a -> Either Error (f a)
  value  :: f a -> a

data OrderId a = OrderId a
                 deriving (Show)

instance SafeConstructor OrderId where
  create str = Right $ OrderId str
  value (OrderId str) = str
