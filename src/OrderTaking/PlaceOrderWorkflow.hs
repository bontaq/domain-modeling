{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE DuplicateRecordFields #-}

module OrderTaking.PlaceOrderWorkflow where

import OrderTaking.Domain
import OrderTaking.DomainApi
import OrderTaking.OrderId

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

type Error = String

only50 str
  | length str > 50 = Left "Name can not be more than 50 chars"
  | otherwise       = Right str

toCustomerInfo :: UnvalidatedCustomerInfo -> Either Error CustomerInfo
toCustomerInfo UnvalidatedCustomerInfo { firstName, lastName, email } =
  let
    first = only50 firstName
    last  = only50 lastName
    personalName = PersonalName <$> first <*> last
  in
    CustomerInfo <$> personalName <*> (Right email)

toAddress :: CheckAddressExists -> UnvalidatedAddress -> Address
toAddress = undefined

validateOrder :: ValidateOrder
validateOrder checkProductCodeExist checkAddressExists unvalidatedOrder =
  let
    orderId' =
      create $ orderId (unvalidatedOrder :: UnvalidatedOrder)
    customerInfo' =
      toCustomerInfo $ customerInfo (unvalidatedOrder :: UnvalidatedOrder)
    shippingAddress' =
      toAddress checkAddressExists
      $ shippingAddress (unvalidatedOrder :: UnvalidatedOrder)
  in
    pure $ Right $ ValidatedOrder {
      orderId = OrderId ""
      , customerInfo = undefined
      , shippingAddress = undefined
      , billingAddress = undefined
      , orderLines = []
    }

data PricingError = PricingError String
type GetProductPrice = ProductCode -> Price

type PriceOrder =
  GetProductPrice    -- dep
  -> ValidatedOrder  -- input
  -> Either PricingError PricedOrder
