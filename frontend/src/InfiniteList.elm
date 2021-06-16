module InfiniteList exposing (Model, Msg(..), init, load_next, to_items, to_last_error, update)

import ApiRoute exposing (ApiRoute)
import ButtonGroup exposing (view_button, view_button_group)
import Dict
import Error
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D


type Msg a
    = GotItems (Result Http.Error (List a))
    | LoadNext


type alias Model a =
    { items : List a
    , last_error : Maybe Error.Error
    , load_size : Int
    , is_loading : Bool
    , all_loaded : Bool
    , request_route : Int -> Int -> ApiRoute
    , decoder : D.Decoder a
    }


update : Msg a -> Model a -> ( Model a, Cmd (Msg a) )
update msg model =
    case msg of
        LoadNext ->
            let
                offset =
                    List.length model.items

                cmd =
                    case ( model.is_loading, model.all_loaded ) of
                        ( False, False ) ->
                            request_http (model.request_route offset model.load_size) model.decoder

                        ( _, _ ) ->
                            Cmd.none
            in
            ( { model | is_loading = True }, cmd )

        GotItems result ->
            case result of
                Ok new_items ->
                    case List.length new_items of
                        0 ->
                            ( { model | is_loading = False, all_loaded = True }, Cmd.none )

                        _ ->
                            ( { model | items = model.items ++ new_items, is_loading = False }, Cmd.none )

                Err e ->
                    ( { model | all_loaded = True, last_error = Just (Error.HttpRequest e) }, Cmd.none )


init : (Int -> Int -> ApiRoute) -> D.Decoder a -> Model a
init request_route decoder =
    { items = []
    , last_error = Nothing
    , load_size = 10
    , is_loading = False
    , all_loaded = False
    , request_route = request_route
    , decoder = decoder
    }


load_next : Msg a
load_next =
    LoadNext


to_items : Model a -> List a
to_items infinite_list =
    infinite_list.items


to_last_error : Model a -> Maybe Error.Error
to_last_error model =
    model.last_error


request_http : ApiRoute -> D.Decoder a -> Cmd (Msg a)
request_http route decoder =
    Http.get
        { url = ApiRoute.to_string route
        , expect = expect_json GotItems decoder
        }


expect_json : (Result Http.Error (List a) -> msg) -> D.Decoder a -> Http.Expect msg
expect_json to_msg decoder =
    Http.expectStringResponse to_msg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ meta body ->
                    Err (Http.BadStatus meta.statusCode)

                Http.GoodStatus_ meta body ->
                    case D.decodeString (D.list decoder) body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (D.errorToString err))
