module Route exposing (Route(..), from_url, parser, replace_url, to_string)

import Browser.Navigation as Nav
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, top)


type Route
    = Home
    | NewProducts
    | Archive
    | Timeline
    | ProductsByCategory
    | Error


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home top
        , map NewProducts (s "new")
        , map Archive (s "archive")
        , map Timeline (s "timeline")
        , map ProductsByCategory (s "category")
        , map Error (s "error")
        ]


from_url : Url.Url -> Maybe Route
from_url url =
    { url | path = url.path ++ Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> parse parser


to_string : Route -> String
to_string route =
    let
        pieces =
            case route of
                Home ->
                    []

                NewProducts ->
                    [ "new" ]

                Archive ->
                    [ "archive" ]

                Timeline ->
                    [ "timeline" ]

                ProductsByCategory ->
                    [ "category" ]

                Error ->
                    [ "error" ]
    in
    "/" ++ String.join "/" pieces


replace_url : Nav.Key -> Route -> Cmd msg
replace_url key route =
    Nav.replaceUrl key (to_string route)
