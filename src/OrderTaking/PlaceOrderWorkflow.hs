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
data CheckedAddress = CheckedAddress Address

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

empty50 :: Foldable t => Maybe (t a) -> Maybe (Either [Char] (t a))
empty50 Nothing    = Nothing
empty50 (Just str) = Just (only50 str)

toCustomerInfo :: UnvalidatedCustomerInfo -> Either Error CustomerInfo
toCustomerInfo UnvalidatedCustomerInfo { firstName, lastName, email } =
  let
    first = only50 firstName
    last  = only50 lastName
    personalName = PersonalName <$> first <*> last
  in
    CustomerInfo <$> personalName <*> (Right email)

toAddress :: CheckAddressExists -> UnvalidatedAddress -> IO (Either AddressValidationError Address)
toAddress checkFn address = do
  checkedAddress <- checkFn address
  case checkedAddress of
    Left e -> pure $ Left e
    Right (CheckedAddress a) -> -- should be type CheckedAddress instead of Address
      let
        addressLine1' = only50 $ addressLine1 (a :: Address)
        addressLine2' = empty50 $ addressLine2 (a :: Address)
        addressLine3' = empty50 $ addressLine3 (a :: Address)
        addressLine4' = empty50 $ addressLine4 (a :: Address)
        city' = city (a :: Address)
        zipCode' = zipCode (a :: Address)
      in
        pure $ Right $ Address <$> addressLine1'

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
