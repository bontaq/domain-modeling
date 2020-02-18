{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.Domain where

import Data.List.NonEmpty
import OrderTaking.UnitQuantity
import OrderTaking.ValidatedAddress

type Result a b = Either a b

data WidgetCode = WidgetCode String
data GizmoCode = GizmoCode String
data ProductCode =
  Widget WidgetCode
  | Gizmo GizmoCode

data KilogramQuantity = KilogramQuantity Float
data OrderQuantity =
  Unit UnitQuantity
  | Kilos KilogramQuantity

type OrderId = String
type OrderLineId = String
type CustomerId = String
type Price = Int

data UnvalidatedAddress = UnvalidatedAddress

type AddressValidationService =
  UnvalidatedAddress -> ValidatedAddress

data CustomerInfo = CustomerInfo
data ShippingAddress = ShippingAddress
data BillingAddress = BillingAddress
data BillingAmount = BillingAmount

data OrderLine = OrderLine {
  id :: OrderLineId
  , orderId :: OrderId
  , productCode :: ProductCode
  , orderQuantity :: OrderQuantity
  , price :: Price
  }

data Order = Order {
  id :: OrderId
  , customerId :: CustomerId
  , shippingAddress :: ValidatedAddress
  , billingAddress :: BillingAddress
  , orderLines :: NonEmpty OrderLine
  , amountToBill :: BillingAmount
  }

data UnvalidatedOrder = UnvalidatedOrder {
  orderId :: OrderId
  , customerInfo :: CustomerInfo
  , shippingAddress :: UnvalidatedAddress
  }

data PlaceOrderEvents =
  AcknowledgmentSent
  | OrderPlaced
  | BillableOrderPlaced

data ValidationError = ValidationError {
  fieldName :: String
  , errorDescription :: String
  }

type PlaceOrderError = [ValidationError]

type PlaceOrder =
  UnvalidatedOrder -> Result PlaceOrderEvents PlaceOrderError
