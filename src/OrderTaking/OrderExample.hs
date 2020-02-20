{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedLabels #-}

import GHC.Records
import GHC.OverloadedLabels (IsLabel(..))
import GHC.TypeLits (Symbol)

instance forall x r a. HasField x r a => IsLabel x (r -> a) where
  fromLabel r = getField @x r

data PersonalName = PersonalName {
  first :: String
  , last :: String
  }

data Customer = Customer {
  customerId :: String
  , name :: PersonalName
  }

data Order = Order {
  customerId :: String
  , items :: [String]
  }

fullName :: Customer -> String
fullName c =
  let
    firstName = #first . #name $ c
    lastName = #last . #name $ c
  in
    firstName <> " " <> lastName

customerIdFromOrder :: Order -> String
customerIdFromOrder = #customerId

test =
  let
    customer = Customer {
      customerId = "1"
      , name = PersonalName {
          first="hello"
          , last="world"
          }
      }
  in
    fullName customer

data Event a = Event {
  content :: a
  , timestamp :: Integer
  }

data MailedEvent = MailedEvent {
  sender :: String
  , receiver :: String
  }

getTimestamp :: Event a -> String
getTimestamp = #timestamp . #content
