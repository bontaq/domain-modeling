{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.PlaceOrderWorkflow where

-- import OrderTaking.DomainApi
import OrderTaking.Domain
import OrderTaking.DomainApi

--
-- Internal state representing the order life cycle
--

type ValidatedOrderLine = OrderLine

data ValidatedOrder = ValidatedOrder {
  orderId :: OrderId
  , customerInfo :: CustomerInfo
  , shippingAddress :: Address
  , billingAddress :: Address
  , orderLines :: [ValidatedOrderLine]
  }

type PricedOrderLine = OrderLine

data PricedOrder = PricedOrder {
  orderId :: OrderId
  , customerInfo :: CustomerInfo
  , shippingAddress :: Address
  , billingAddress :: Address
  , orderLines :: [PricedOrderLine]
  , amountToBill :: BillingAmount
  }

data Order =
  Unvalidated UnvalidatedOrder
  | Validated ValidatedOrder
  | Priced PricedOrder

--
-- Internal steps
--

--
-- Services
--
type CheckProductCodeExists =
  ProductCode -> Bool

data AddressValidationError = AddressValidationError String
data CheckedAddress = CheckedAddress UnvalidatedAddress

type CheckAddressExists =
  UnvalidatedAddress -> AsyncResult AddressValidationError CheckedAddress

type ValidateOrder =
  CheckProductCodeExists  -- dep
  -> CheckAddressExists   -- dep
  -> UnvalidatedOrder     -- input
  -> AsyncResult [ValidationError] ValidatedOrder

data PricingError = PricingError String
type GetProductPrice = ProductCode -> Price

type PriceOrder =
  GetProductPrice    -- dep
  -> ValidatedOrder  -- input
  -> Either PricingError PricedOrder
