module Page.ProductsByCategory exposing (..)

import Api.Category exposing (Category)
import Api.Product exposing (Product)
import ApiRoute
import Browser
import Browser.Navigation as Nav
import ButtonGroup exposing (view_button_dropdown, view_button_group_dropdown)
import Error
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Page exposing (ViewInfo)
import ProductTable exposing (view_product_table)
import Route
import Task
import Time
import Utility exposing (timestamp_to_dmy, wrap_row_col)


type alias Model =
    { nav_key : Nav.Key
    , active_category : Maybe Category
    , categories : Maybe (List Category)
    , products : Maybe (List Product)
    , last_error : Maybe Error.Error
    }


type Msg
    = RequestCategories
    | RequestProducts (Maybe Category)
    | GotCategories (Result Http.Error (List Category))
    | GotProducts (Result Http.Error (List Product))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestCategories ->
            ( model, request_categories )

        RequestProducts maybe_category ->
            ( { model | active_category = maybe_category }, request_products maybe_category )

        GotCategories result ->
            case result of
                Ok categories ->
                    let
                        active_category =
                            List.head categories
                    in
                    ( { model | categories = Just categories, active_category = active_category }, request_products active_category )

                Err e ->
                    ( { model | last_error = Just (Error.HttpRequest e) }, Route.replace_url (to_nav_key model) Route.Error )

        GotProducts result ->
            case result of
                Ok products ->
                    ( { model | products = Just products }, Cmd.none )

                Err e ->
                    ( { model | last_error = Just (Error.HttpRequest e) }, Route.replace_url (to_nav_key model) Route.Error )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> ViewInfo Msg
view model =
    let
        product_table =
            case model.products of
                Just products ->
                    view_product_table True <|
                        List.reverse <|
                            List.sortBy (\p -> p.first_seen) products

                Nothing ->
                    div [] []

        active_product_count =
            case model.products of
                Just p ->
                    List.length p

                Nothing ->
                    0
    in
    { title = "{{ PAGE.TITLE }}"
    , caption = "{{ PAGE.CATEGORY.CAPTION }}"
    , content = div [] [ div [ class "row my-3" ] [ div [ class "col" ] [ view_categories model.active_category model.categories active_product_count ] ], wrap_row_col product_table ]
    }


to_nav_key : Model -> Nav.Key
to_nav_key model =
    model.nav_key


to_last_error : Model -> Maybe Error.Error
to_last_error model =
    model.last_error


request_categories : Cmd Msg
request_categories =
    Http.get
        { url = ApiRoute.to_string ApiRoute.ListCategories
        , expect = Http.expectJson GotCategories Api.Category.list_decoder
        }


request_products : Maybe Category -> Cmd Msg
request_products maybe_category =
    let
        cat_string =
            Maybe.andThen (\c -> Just c.name) maybe_category
    in
    Http.get
        { url = ApiRoute.to_string (ApiRoute.ProductsByCategory { name = cat_string })
        , expect = Http.expectJson GotProducts Api.Product.list_decoder
        }


view_categories : Maybe Category -> Maybe (List Category) -> Int -> Html Msg
view_categories maybe_active_category maybe_categories active_product_count =
    case maybe_categories of
        Just cats ->
            let
                buttons : (Msg -> Bool -> String -> Html Msg) -> List (Html Msg)
                buttons wrap_fn =
                    List.map (\c -> wrap_fn (RequestProducts (Just c)) (Just c == maybe_active_category) c.name) cats ++ [ wrap_fn (RequestProducts Nothing) (Nothing == maybe_active_category) "{{ LABEL.NO_CATEGORY }}" ]

                active_string =
                    List.foldr (++)
                        ""
                        [ ": "
                        , case maybe_active_category of
                            Just cat ->
                                cat.name

                            Nothing ->
                                "{{ LABEL.NO_CATEGORY }}"
                        , " (" ++ String.fromInt active_product_count ++ ")"
                        ]
            in
            view_button_group_dropdown ("{{ LABEL.CATEGORY }}" ++ active_string) <| buttons view_button_dropdown

        Nothing ->
            div [] []


to_dropdown_element : Msg -> Category -> Category -> String -> Html Msg
to_dropdown_element msg button_timespan active_timespan label_string =
    let
        focus_class =
            if active_timespan == button_timespan then
                " focus"

            else
                ""
    in
    label [ class <| "btn btn-block" ++ focus_class, attribute "style" "border-radius: 0px; margin: 0px;" ]
        [ input
            [ class "d-none"
            , type_ "radio"
            , name "timespan"
            , attribute "autocomplete" "off"
            , onClick msg
            ]
            []
        , text label_string
        ]


init : Nav.Key -> ( Model, Cmd Msg )
init nav_key =
    ( { nav_key = nav_key
      , active_category = Nothing
      , categories = Nothing
      , products = Nothing
      , last_error = Nothing
      }
    , request_categories
    )
