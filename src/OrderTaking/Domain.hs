{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.Domain where

import Data.List.NonEmpty
import Data.Time
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

data UnvalidatedCustomerInfo = UnvalidatedCustomerInfo
-- data UnvalidatedAddress = UnvalidatedAddress

-- type AddressValidationService =
--   UnvalidatedAddress -> ValidatedAddress

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

-- type ValidatedOrderLine = OrderLine

-- data ValidatedOrder = ValidatedOrder {
--   orderId :: OrderId
--   , customerInfo :: CustomerInfo
--   , shippingAddress :: Address
--   , billingAddress :: Address
--   , orderLines :: [ValidatedOrderLine]
--   }

-- type PricedOrderLine = OrderLine

-- data PricedOrder = PricedOrder {
--   orderId :: OrderId
--   , customerInfo :: CustomerInfo
--   , shippingAddress :: Address
--   , billingAddress :: Address
--   , orderLines :: [PricedOrderLine]
--   , amountToBill :: BillingAmount
--   }

-- data UnvalidatedOrder = UnvalidatedOrder {
--   orderId :: String
--   , customerInfo :: UnvalidatedCustomerInfo
--   , shippingAddress :: UnvalidatedAddress
--   }

-- data Order =
--   Unvalidated UnvalidatedOrder
--   | Validated ValidatedOrder
--   | Priced PricedOrder

-- data PlaceOrderEvent =
--   AcknowledgmentSent OrderAcknowledgementSent
--   | OrderPlaced OrderPlacedEvent
--   | BillableOrderPlaced BillableOrderPlacedEvent

data ValidationError = ValidationError {
  fieldName :: String
  , errorDescription :: String
  }

-- type PlaceOrderError = [ValidationError]


data Command a = Command {
  content :: a
  , timestamp :: UTCTime
  , userId :: String
  }

-- type PlaceOrder = Command UnvalidatedOrder
-- type ChangeOrder = Command UnvalidatedOrder
-- type CancelOrder = Command UnvalidatedOrder

-- data OrderTakingCommand =
--   Place PlaceOrder
--   | Change ChangeOrder
--   | Cancel CancelOrder

-- type CheckProductCodeExists =
--   ProductCode -> Bool

-- data CheckedAddress = CheckedAddress UnvalidatedAddress

-- data AddressValidationError = AddressValidationError String

-- type CheckAddressExists =
--   UnvalidatedAddress -> AsyncResult AddressValidationError CheckedAddress

-- type ValidateOrder =
--   CheckProductCodeExists  -- dep
--   -> CheckAddressExists   -- dep
--   -> UnvalidatedOrder     -- input
--   -> AsyncResult [ValidationError] ValidatedOrder

type GetProductPrice = ProductCode -> Price

data PricingError = PricingError String

-- type PriceOrder =
--   GetProductPrice    -- dep
--   -> ValidatedOrder  -- input
--   -> Either PricingError PricedOrder

type EmailAddress = String
data HtmlString = HtmlString String

data OrderAcknowledgement = OrderAcknowledgement {
  emailAddress :: EmailAddress
  , letter :: HtmlString
  }

-- type CreateOrderAcknowledgmentLetter =
--   PricedOrder -> HtmlString

data SendResult = Send | NotSent

type SendOrderAcknowledgment =
  OrderAcknowledgement -> SendResult

-- data OrderAcknowledgementSent = OrderAcknowledgementSent {
--   orderId :: OrderId
--   , emailAddress :: EmailAddress
--   }

-- type AcknowledgeOrder =
--   CreateOrderAcknowledgmentLetter
--   -> SendOrderAcknowledgment -- async dep
--   -> PricedOrder
--   -> IO (Maybe OrderAcknowledgementSent)

--
-- Events
--

-- type OrderPlacedEvent = PricedOrder

data BillableOrderPlacedEvent = BillableOrderPlacedEvent {
  orderId :: OrderId
  , billingAddress :: Address
  , amountToBill :: BillingAmount
  }

type AsyncResult failure success = IO (Either failure success)

-- type CreateEvents =
--   PricedOrder -> [PlaceOrderEvent]

-- -- The Main Thing
-- type PlaceOrderWorkflow =
--   PlaceOrder -> AsyncResult PlaceOrderError [PlaceOrderEvent]
