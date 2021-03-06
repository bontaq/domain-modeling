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
import OrderTaking.UnitQuantity
import OrderTaking.KilogramQuantity

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
  , productCode :: ProductCode
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

-- predicatePassThrough :: Error -> (a -> Bool) -> a -> Either Error a
-- predicatePassThrough errMsg fn val =
--   case fn val of
--     True   -> Right val
--     False  -> Left errMsg

toValidatedOrderLine
  :: CheckProductCodeExists
  -> UnvalidatedOrderLine
  -> IO (Either OrderLineValidationError ValidatedOrderLine)
toValidatedOrderLine checkProductFn unvalidatedOrder = do
  checkedProductCode <- checkProductFn $ #productCode unvalidatedOrder

  -- TODO: use neat idea with predicatePassThrough
  -- let checkProduct productCode =
  --       predicatePassThrough "Invalid product code" checkProductFn productCode

  case checkedProductCode of
    True ->
      let
        orderLineId' = create $ #orderLineId unvalidatedOrder
        -- TODO: fix
        productCode' = Right $ Gizmo $ GizmoCode $ #productCode unvalidatedOrder
        quantity'    = Right $ #quantity unvalidatedOrder
      in
         pure $ ValidatedOrderLine
          <$> orderLineId' <*> productCode' <*> quantity'
    False ->
      pure $ Left "ProductCode does not exist"

toOrderQuantity :: ProductCode -> Int -> Either String OrderQuantity
toOrderQuantity productCode quantity =
  case productCode of
    Widget _ ->
      Unit <$> createUnitQuantity quantity
    Gizmo _ ->
      Kilos <$> createKilogramQuantity quantity

validateOrder :: ValidateOrder
validateOrder checkProductCodeExists checkAddressExists unvalidatedOrder =
  let
    orderId' =
      create $ #orderId unvalidatedOrder

    customerInfo' =
      toCustomerInfo $ #customerInfo unvalidatedOrder

    shippingAddress' =
      toAddress checkAddressExists
        $ #shippingAddress unvalidatedOrder

    orderLines' =
      fmap
        (toValidatedOrderLine checkProductCodeExists)
        (#orderLines unvalidatedOrder)
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
  -> AsyncResult PricingError PricedOrder

toPricedOrderLine
  :: GetProductPrice
  -> ValidatedOrderLine
  -> Either PricingError PricedOrderLine
toPricedOrderLine getProductPrice orderLine =
  let
    price' = getProductPrice (#productCode orderLine)
  in
    undefined

priceOrder :: PriceOrder
priceOrder getProductPrice validatedOrder =
  let lines =
        fmap
          (toPricedOrderLine getProductPrice)
          (#orderLines validatedOrder)
      amountToBill =
        -- TODO: bad, but works
        sum $ fmap sum $ fmap (fmap $ #price) lines
  in
    pure $ Right $ PricedOrder {
      orderId = #orderId validatedOrder
      , customerInfo = #customerInfo validatedOrder
      , shippingAddress = #shippingAddress validatedOrder
      , billingAddress = #billingAddress validatedOrder
      , orderLines = fmap (\(Right a) -> a) lines
      , amountToBill = amountToBill
    }
