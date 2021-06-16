module Page.Archive exposing (Model, Msg, init, subscriptions, to_last_error, to_nav_key, update, view)

import Api.Product exposing (Product)
import ApiRoute
import Browser
import Browser.Navigation as Nav
import Error
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import InfiniteList
import Page exposing (ViewInfo)
import Ports exposing (message_receiver)
import ProductTable exposing (view_product_table)
import Route
import Task
import Time
import Utility exposing (timestamp_to_dmy, wrap_row_col)


type alias Model =
    { nav_key : Nav.Key
    , infinite_list : InfiniteList.Model Product
    , last_error : Maybe Error.Error
    }


type Msg
    = GotInfiniteListMsg (InfiniteList.Msg Product)
    | GotPortMsg String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPortMsg port_msg ->
            let
                updated =
                    InfiniteList.update InfiniteList.load_next model.infinite_list
                        |> update_with (\m -> \sm -> { m | infinite_list = sm }) GotInfiniteListMsg model
            in
            updated

        GotInfiniteListMsg sub_msg ->
            let
                updated =
                    InfiniteList.update sub_msg model.infinite_list
                        |> update_with (\m -> \sm -> { m | infinite_list = sm }) GotInfiniteListMsg model
            in
            case InfiniteList.to_last_error (Tuple.first updated).infinite_list of
                Just err ->
                    ( { model | last_error = Just err }, Route.replace_url (to_nav_key model) Route.Error )

                Nothing ->
                    updated


subscriptions : Model -> Sub Msg
subscriptions model =
    message_receiver GotPortMsg


view : Model -> ViewInfo Msg
view model =
    let
        product_table =
            view_product_table True (InfiniteList.to_items model.infinite_list)
    in
    { title = "{{ PAGE.TITLE }}"
    , caption = " {{ PAGE.ARCHIVE.CAPTION }}"
    , content = div [] [ wrap_row_col product_table ]
    }


update_with : (Model -> sub_model -> Model) -> (sub_msg -> Msg) -> Model -> ( sub_model, Cmd sub_msg ) -> ( Model, Cmd Msg )
update_with to_model to_msg model ( sub_model, sub_cmd ) =
    ( to_model model sub_model
    , Cmd.map to_msg sub_cmd
    )


to_nav_key : Model -> Nav.Key
to_nav_key model =
    model.nav_key


to_last_error : Model -> Maybe Error.Error
to_last_error model =
    model.last_error


to_infinite_list : Model -> InfiniteList.Model Product
to_infinite_list model =
    model.infinite_list


init : Nav.Key -> ( Model, Cmd Msg )
init nav_key =
    let
        initial_list =
            InfiniteList.init (\offset -> \size -> ApiRoute.ProductArchive { offset = Just offset, size = Just size }) Api.Product.decoder

        initial_model =
            { nav_key = nav_key
            , infinite_list = initial_list
            , last_error = Nothing
            }

        updated_model =
            InfiniteList.update InfiniteList.LoadNext initial_list
                |> update_with (\m -> \sm -> { m | infinite_list = sm }) GotInfiniteListMsg initial_model
    in
    updated_model
