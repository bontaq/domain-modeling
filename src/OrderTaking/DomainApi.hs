{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.DomainApi where

import Data.Time
import OrderTaking.Domain (AsyncResult, Address, EmailAddress, BillingAmount, ValidationError)
import OrderTaking.OrderId
-- import OrderTaking.PlaceOrderWorkflow (PricedOrder, ValidationError)

--
-- Input data
--

data UnvalidatedCustomerInfo = UnvalidatedCustomerInfo {
  firstName :: String
  , lastName :: String
  -- , name :: String
  , email :: String
  }

data UnvalidatedAddress = UnvalidatedAddress {
  addressLine1 :: String
  , addressLine2 :: String
  , addressLine3 :: String
  , addressLine4 :: String
  , city :: String
  , zipCode :: String
  }

data UnvalidatedOrder = UnvalidatedOrder {
  orderId :: String
  , customerInfo :: UnvalidatedCustomerInfo
  , shippingAddress :: UnvalidatedAddress
  }

--
-- Input Command
--

data Command a = Command {
  content :: a
  , timestamp :: UTCTime
  , userId :: String
  }

type PlaceOrderCommand = Command UnvalidatedOrder

--
-- Public API
--

data OrderAcknowledgementSent = OrderAcknowledgementSent {
  orderId :: OrderId
  , emailAddress :: EmailAddress
  }

data OrderPlacedEvent = OrderPlacedEvent

data BillableOrderPlacedEvent = BillableOrderPlacedEvent {
  orderId :: OrderId
  , billingAddress :: Address
  , amountToBill :: BillingAmount
  }

data PlaceOrderEvent =
  AcknowledgmentSent OrderAcknowledgementSent
  | OrderPlaced OrderPlacedEvent
  | BillableOrderPlaced BillableOrderPlacedEvent

type PlaceOrderError = [ValidationError]

type PlaceOrder =
  UnvalidatedOrder -> Either PlaceOrderError [PlaceOrderEvent]

type PlaceOrderWorkflow =
  PlaceOrder -> AsyncResult PlaceOrderError [PlaceOrderEvent]
