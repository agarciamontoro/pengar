module Balance exposing
    ( Balance
    , balanceDecoder
    , getFirstCommodityBalance
    , getFirstEuroBalance
    , isOfCommodity
    , quantityDecoder
    )

import Commodity exposing (Commodity)
import Json.Decode as Decode exposing (Decoder)


type alias Balance =
    { commodity : Commodity
    , quantity : Float
    }


balanceDecoder : Decoder Balance
balanceDecoder =
    Decode.map2 Balance
        (Decode.field "acommodity" Decode.string |> Decode.andThen Commodity.commodityDecoder)
        (Decode.field "aquantity" quantityDecoder)


quantityDecoder : Decoder Float
quantityDecoder =
    let
        quantityFromJSON decimalPlaces decimalMantissa =
            toFloat decimalMantissa / toFloat (10 ^ decimalPlaces)
    in
    Decode.map2 quantityFromJSON
        (Decode.field "decimalPlaces" Decode.int)
        (Decode.field "decimalMantissa" Decode.int)


isOfCommodity : Commodity -> Balance -> Bool
isOfCommodity commodity balance =
    balance.commodity == commodity


getFirstCommodityBalance : Commodity -> List Balance -> Float
getFirstCommodityBalance commodity balances =
    case List.head (List.filter (isOfCommodity commodity) balances) of
        Nothing ->
            0

        Just balance ->
            balance.quantity


getFirstEuroBalance : List Balance -> Float
getFirstEuroBalance =
    getFirstCommodityBalance Commodity.Euro
