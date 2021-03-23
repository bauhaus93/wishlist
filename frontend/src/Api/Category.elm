module Api.Category exposing (Category, decoder, list_decoder)

import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E


type alias Category =
    { name : String
    }


decoder : D.Decoder Category
decoder =
    D.succeed Category
        |> required "name" D.string


list_decoder : D.Decoder (List Category)
list_decoder =
    D.list decoder
