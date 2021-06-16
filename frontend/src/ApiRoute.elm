module ApiRoute exposing (ApiRoute(..), ArchiveQuery, TimelineQuery, from_url, parser, to_string)

import Url
import Url.Parser exposing ((</>), (<?>), Parser, map, oneOf, parse, s, top)
import Url.Parser.Query as Query


type ApiRoute
    = LastWishlist
    | NewProducts
    | ProductArchive ArchiveQuery
    | Timeline TimelineQuery
    | ProductsByCategory CategoryQuery
    | ListCategories


type alias ArchiveQuery =
    { offset : Maybe Int
    , size : Maybe Int
    }


type alias CategoryQuery =
    { name : Maybe String
    }


type alias TimelineQuery =
    { from_timestamp : Maybe Int
    , count : Maybe Int
    }


timeline_query : Query.Parser TimelineQuery
timeline_query =
    Query.map2 TimelineQuery (Query.int "from_timestamp") (Query.int "count")


category_query : Query.Parser CategoryQuery
category_query =
    Query.map CategoryQuery (Query.string "category")


archive_query : Query.Parser ArchiveQuery
archive_query =
    Query.map2 ArchiveQuery (Query.int "offset") (Query.int "size")


parser : Parser (ApiRoute -> a) a
parser =
    oneOf
        [ map LastWishlist (s "api" </> s "wishlist" </> s "last")
        , map NewProducts (s "api" </> s "product" </> s "newest")
        , map ProductArchive (s "api" </> s "product" </> s "archive" <?> archive_query)
        , map ProductsByCategory (s "api" </> s "product" </> s "category" <?> category_query)
        , map ListCategories (s "api" </> s "category" </> s "list")
        , map Timeline (s "api" </> s "timeline" </> s "points" <?> timeline_query)
        ]


from_url : Url.Url -> Maybe ApiRoute
from_url url =
    { url | path = url.path ++ Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> parse parser


to_string : ApiRoute -> String
to_string route =
    let
        path_pieces =
            case route of
                LastWishlist ->
                    [ "api", "wishlist", "last" ]

                NewProducts ->
                    [ "api", "product", "newest" ]

                ProductArchive _ ->
                    [ "api", "product", "archive" ]

                ProductsByCategory _ ->
                    [ "api", "product", "category" ]

                ListCategories ->
                    [ "api", "category", "list" ]

                Timeline _ ->
                    [ "api", "wishlist", "values" ]

        query_pieces =
            case route of
                ProductArchive q ->
                    [ ( "offset", String.fromInt <| Maybe.withDefault 0 q.offset )
                    , ( "size", String.fromInt <| Maybe.withDefault 10 q.size )
                    ]

                ProductsByCategory q ->
                    case q.name of
                        Just name ->
                            [ ( "category", name ) ]

                        Nothing ->
                            []

                Timeline q ->
                    [ ( "from_timestamp", String.fromInt <| Maybe.withDefault 0 q.from_timestamp )
                    , ( "count", String.fromInt <| Maybe.withDefault 10 q.count )
                    ]

                _ ->
                    []

        query =
            case List.length query_pieces of
                0 ->
                    ""

                _ ->
                    "?"
                        ++ String.join "&" (List.map (\p -> Tuple.first p ++ "=" ++ Tuple.second p) query_pieces)
    in
    "/" ++ String.join "/" path_pieces ++ query
