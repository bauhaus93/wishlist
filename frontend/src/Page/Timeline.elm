module Page.Timeline exposing (Model, Msg, init, to_last_error, to_nav_key, update, view)

import Api.Datapoint exposing (Datapoint)
import ApiRoute
import Browser
import Browser.Navigation as Nav
import ButtonGroup exposing (view_button, view_button_dropdown, view_button_group, view_button_group_dropdown)
import Error
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Page exposing (ViewInfo)
import Route
import Task
import Time
import Utility exposing (timestamp_to_dm, timestamp_to_hm, wrap_responsive_alternative_sm, wrap_row_col, wrap_row_col_centered)


type alias Model =
    { nav_key : Nav.Key
    , last_error : Maybe Error.Error
    , active_timespan : ActiveTimespan
    }


type ActiveTimespan
    = Last30Days
    | Last100Days
    | Overall


type Msg
    = RequestLast30Days
    | RequestLast100Days
    | RequestOverall


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestLast30Days ->
            ( { model | active_timespan = Last30Days }, Cmd.none )

        RequestLast100Days ->
            ( { model | active_timespan = Last100Days }, Cmd.none )

        RequestOverall ->
            ( { model | active_timespan = Overall }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


mongodb_chart_url : ActiveTimespan -> String
mongodb_chart_url timespan =
    case timespan of
        Last30Days ->
            "https://charts.mongodb.com/charts-wishlist-xmzdv/embed/charts?id=8d0bc72b-671b-4fd2-8bee-156fd2552509&theme=light"

        Last100Days ->
            "https://charts.mongodb.com/charts-wishlist-xmzdv/embed/charts?id=da638af3-b241-4ec6-bb67-016b38fc1c25&theme=light"

        Overall ->
            "https://charts.mongodb.com/charts-wishlist-xmzdv/embed/charts?id=f5f9b659-0945-4566-acc5-4b661d347010&theme=light"


view : Model -> ViewInfo Msg
view model =
    { title = "{{ PAGE.TITLE }}"
    , caption = "{{ PAGE.TIMELINE.CAPTION }}"
    , content =
        div []
            [ wrap_row_col <| view_iframe <| mongodb_chart_url model.active_timespan
            , wrap_row_col <|
                div [ class "my-3 mx-3" ]
                    [ view_request_buttons model.active_timespan
                    ]
            ]
    }


view_iframe : String -> Html Msg
view_iframe src_url =
    div [ class "embed-responsive embed-responsive-4by3" ] [ iframe [ class "embed-responsive-item", src src_url ] [] ]


view_request_buttons : ActiveTimespan -> Html Msg
view_request_buttons active_timespan =
    let
        buttons : (Msg -> Bool -> String -> Html Msg) -> List (Html Msg)
        buttons wrap_fn =
            [ wrap_fn RequestLast30Days (active_timespan == Last30Days) "{{ LABEL.LAST_30DAYS }}"
            , wrap_fn RequestLast100Days (active_timespan == Last100Days) "{{ LABEL.LAST_100DAYS }}"
            , wrap_fn RequestOverall (active_timespan == Overall) "{{ LABEL.OVERALL }}"
            ]
    in
    wrap_responsive_alternative_sm
        (div [ class "text-right" ] [ view_button_group_dropdown "{{ LABEL.TIMESPAN }}" <| buttons view_button_dropdown ])
        (div [ class "text-center" ] [ view_button_group (buttons view_button) ])


to_grouped_button : Msg -> ActiveTimespan -> ActiveTimespan -> String -> Html Msg
to_grouped_button msg button_timespan active_timespan label_string =
    let
        focus_class =
            if active_timespan == button_timespan then
                " focus"

            else
                ""
    in
    label [ class <| "btn btn-secondary" ++ focus_class ]
        [ input
            [ type_ "radio"
            , name "timespan"
            , attribute "autocomplete" "off"
            , onClick msg
            ]
            []
        , text label_string
        ]


to_dropdown_element : Msg -> ActiveTimespan -> ActiveTimespan -> String -> Html Msg
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


to_nav_key : Model -> Nav.Key
to_nav_key model =
    model.nav_key


to_last_error : Model -> Maybe Error.Error
to_last_error model =
    model.last_error


init : Nav.Key -> ( Model, Cmd Msg )
init nav_key =
    ( { nav_key = nav_key
      , last_error = Nothing
      , active_timespan = Overall
      }
    , Cmd.none
    )
