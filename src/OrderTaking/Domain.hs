{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.Domain where

import Data.List.NonEmpty
import Data.Time
import OrderTaking.UnitQuantity
import OrderTaking.ValidatedAddress
import OrderTaking.OrderId

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

type OrderLineId = String
type CustomerId = String
type Price = Int

data UnvalidatedCustomerInfo = UnvalidatedCustomerInfo

data CustomerInfo = CustomerInfo
data ShippingAddress = ShippingAddress
data BillingAddress = BillingAddress
data Address = Address
data BillingAmount = BillingAmount

data OrderLine = OrderLine {
  id :: OrderLineId
  , orderId :: OrderId
  , productCode :: ProductCode
  , orderQuantity :: OrderQuantity
  , price :: Price
  }

data ValidationError = ValidationError {
  fieldName :: String
  , errorDescription :: String
  }

data Command a = Command {
  content :: a
  , timestamp :: UTCTime
  , userId :: String
  }


type EmailAddress = String
data HtmlString = HtmlString String

data OrderAcknowledgement = OrderAcknowledgement {
  emailAddress :: EmailAddress
  , letter :: HtmlString
  }

data SendResult = Send | NotSent

type SendOrderAcknowledgment =
  OrderAcknowledgement -> SendResult

--
-- Events
--

data BillableOrderPlacedEvent = BillableOrderPlacedEvent {
  orderId :: OrderId
  , billingAddress :: Address
  , amountToBill :: BillingAmount
  }

type AsyncResult failure success = IO (Either failure success)
