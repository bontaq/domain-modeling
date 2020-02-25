{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedLabels #-}

module OrderTaking.PlaceOrderWorkflow where

import OrderTaking.Domain
import OrderTaking.DomainApi
import OrderTaking.OrderId

import GHC.Records
import GHC.OverloadedLabels (IsLabel(..))
import GHC.TypeLits (Symbol)

instance forall x r a. HasField x r a => IsLabel x (r -> a) where
  fromLabel r = getField @x r

--
-- Internal state representing the order life cycle
--

data ValidatedOrderLine = ValidatedOrderLine {
  orderLineId :: OrderId
  , productCode :: String
  , quantity :: Integer
  }

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
  String -> IO Bool
  -- TODO: ProductCode -> IO Bool

type AddressValidationError = String
data CheckedAddress = CheckedAddress Address

type CheckAddressExists =
  UnvalidatedAddress -> AsyncResult AddressValidationError CheckedAddress

type OrderLineValidationError = String

type ValidateOrder =
  CheckProductCodeExists  -- dep
  -> CheckAddressExists   -- dep
  -> UnvalidatedOrder     -- input
  -> AsyncResult [ValidationError] ValidatedOrder

type Error = String

only50 str
  | length str > 50 = Left "Name can not be more than 50 chars"
  | otherwise       = Right str

-- empty50 :: Maybe a -> (Either [Char] (Maybe a))
-- empty50 :: (Maybe a) -> Either [Char] (Maybe b)
empty50 :: Foldable t => Maybe (t a) -> Either [Char] (Maybe (t a))
empty50 Nothing    = Right Nothing
empty50 (Just str) = case only50 str of
  Right str -> Right $ Just str
  Left err  -> Left err

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
        addressLine1' = only50 $ #addressLine1 a
        addressLine2' = empty50 $ #addressLine2 a
        addressLine3' = empty50 $ #addressLine3 a
        addressLine4' = empty50 $ #addressLine4 a
        city' = #city a
        zipCode' = #zipCode a
      in
        pure $ Address
          <$> addressLine1'
          <*> addressLine2'
          <*> addressLine3'
          <*> addressLine4'
          <*> (Right city')
          <*> (Right zipCode')

toValidatedOrder
  :: CheckProductCodeExists
  -> UnvalidatedOrderLine
  -> IO (Either OrderLineValidationError ValidatedOrderLine)
toValidatedOrder checkProductFn unvalidatedOrder = do
  checkedProductCode <- checkProductFn $ #productCode unvalidatedOrder
  case checkedProductCode of
    True ->
      let
        orderLineId' = create $ #orderLineId unvalidatedOrder
        productCode' = Right $ #productCode unvalidatedOrder
        quantity'    = Right $ #quantity unvalidatedOrder
      in
         pure $ ValidatedOrderLine
          <$> orderLineId' <*> productCode' <*> quantity'

validateOrder :: ValidateOrder
validateOrder checkProductCodeExist checkAddressExists unvalidatedOrder =
  let
    orderId' =
      create $ #orderId unvalidatedOrder
    customerInfo' =
      toCustomerInfo $ #customerInfo unvalidatedOrder
    shippingAddress' =
      toAddress checkAddressExists
      $ #shippingAddress unvalidatedOrder
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
