module Main exposing (Model(..), Msg(..), change_route, init, main, subscriptions, update, update_with, view)

import Browser
import Browser.Navigation as Nav
import Error
import Html exposing (..)
import Http
import Page
import Page.Archive as Archive
import Page.Empty as Empty
import Page.Error as Error
import Page.Home as Home
import Page.NewProducts as NewProducts
import Page.ProductsByCategory as ProductsByCategory
import Page.Timeline as Timeline
import Route
import Url


type Model
    = Home Home.Model
    | NewProducts NewProducts.Model
    | Archive Archive.Model
    | Timeline Timeline.Model
    | ProductsByCategory ProductsByCategory.Model
    | Error Error.Model
    | Redirect Nav.Key


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotNewProductsMsg NewProducts.Msg
    | GotArchiveMsg Archive.Msg
    | GotProductsByCategoryMsg ProductsByCategory.Msg
    | GotTimelineMsg Timeline.Msg
    | GotErrorMsg Error.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UrlChanged url, _ ) ->
            change_route (Route.from_url url) model

        ( LinkClicked request, _ ) ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (to_nav_key model) (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ( GotHomeMsg sub_msg, Home home ) ->
            Home.update sub_msg home
                |> update_with Home GotHomeMsg model

        ( GotNewProductsMsg sub_msg, NewProducts new_products ) ->
            NewProducts.update sub_msg new_products
                |> update_with NewProducts GotNewProductsMsg model

        ( GotArchiveMsg sub_msg, Archive archive ) ->
            Archive.update sub_msg archive
                |> update_with Archive GotArchiveMsg model

        ( GotTimelineMsg sub_msg, Timeline timeline ) ->
            Timeline.update sub_msg timeline
                |> update_with Timeline GotTimelineMsg model

        ( GotProductsByCategoryMsg sub_msg, ProductsByCategory prod_by_cat ) ->
            ProductsByCategory.update sub_msg prod_by_cat
                |> update_with ProductsByCategory GotProductsByCategoryMsg model

        ( GotErrorMsg sub_msg, Error error ) ->
            Error.update sub_msg error
                |> update_with Error GotErrorMsg model

        -- BEWARE CATCHES ALL LEFT, do not forget to add msg entry for new page
        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Archive sub_model ->
            Archive.subscriptions sub_model
                |> Sub.map GotArchiveMsg

        _ ->
            Sub.none


view : Model -> Browser.Document Msg
view model =
    let
        view_page page to_msg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Html.map to_msg) body
            }
    in
    case model of
        Home home ->
            view_page Page.Home GotHomeMsg (Home.view home)

        NewProducts new_products ->
            view_page Page.NewProducts GotNewProductsMsg (NewProducts.view new_products)

        Archive archive ->
            view_page Page.Archive GotArchiveMsg (Archive.view archive)

        Timeline timeline ->
            view_page Page.Timeline GotTimelineMsg (Timeline.view timeline)

        ProductsByCategory prod_by_cat ->
            view_page Page.ProductsByCategory GotProductsByCategoryMsg (ProductsByCategory.view prod_by_cat)

        Error error ->
            view_page Page.Error GotErrorMsg (Error.view error)

        Redirect _ ->
            Page.view Page.Other Empty.view


to_nav_key : Model -> Nav.Key
to_nav_key model =
    case model of
        Home home ->
            Home.to_nav_key home

        NewProducts new_products ->
            NewProducts.to_nav_key new_products

        Archive archive ->
            Archive.to_nav_key archive

        Timeline timeline ->
            Timeline.to_nav_key timeline

        ProductsByCategory prod_by_cat ->
            ProductsByCategory.to_nav_key prod_by_cat

        Error error ->
            Error.to_nav_key error

        Redirect nav_key ->
            nav_key


to_last_error : Model -> Maybe Error.Error
to_last_error model =
    case model of
        Home home ->
            Home.to_last_error home

        NewProducts new_products ->
            NewProducts.to_last_error new_products

        Archive archive ->
            Archive.to_last_error archive

        Timeline timeline ->
            Timeline.to_last_error timeline

        ProductsByCategory prod_by_cat ->
            ProductsByCategory.to_last_error prod_by_cat

        Error error ->
            Error.to_last_error error

        Redirect _ ->
            Nothing


change_route : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
change_route maybe_route model =
    case maybe_route of
        Nothing ->
            Home.init (to_nav_key model)
                |> update_with Home GotHomeMsg model

        Just Route.Home ->
            Home.init (to_nav_key model)
                |> update_with Home GotHomeMsg model

        Just Route.NewProducts ->
            NewProducts.init (to_nav_key model)
                |> update_with NewProducts GotNewProductsMsg model

        Just Route.Archive ->
            Archive.init (to_nav_key model)
                |> update_with Archive GotArchiveMsg model

        Just Route.Timeline ->
            Timeline.init (to_nav_key model)
                |> update_with Timeline GotTimelineMsg model

        Just Route.ProductsByCategory ->
            ProductsByCategory.init (to_nav_key model)
                |> update_with ProductsByCategory GotProductsByCategoryMsg model

        Just Route.Error ->
            case to_last_error model of
                Just err ->
                    Error.init (to_nav_key model) err
                        |> update_with Error GotErrorMsg model

                Nothing ->
                    change_route (Just Route.Home) model


update_with : (sub_model -> Model) -> (sub_msg -> Msg) -> Model -> ( sub_model, Cmd sub_msg ) -> ( Model, Cmd Msg )
update_with to_model to_msg model ( sub_model, sub_cmd ) =
    ( to_model sub_model
    , Cmd.map to_msg sub_cmd
    )


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url nav_key =
    change_route (Route.from_url url) (Redirect nav_key)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
