module Route exposing
    ( Route(..)
    , href
    , parse
    , unparse
    )

import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url
import Url.Builder
import Url.Parser as Parser exposing ((</>))


type Route
    = Home
      -- Should be QuizId
    | Quiz String
    | NotFound


href : Route -> Attribute msg
href route =
    unparse route
        |> Attributes.href


parse : Url.Url -> Route
parse url =
    let
        pathParser =
            Parser.oneOf
                [ Parser.map Home Parser.top
                , Parser.map Quiz <| Parser.s "quiz" </> Parser.string
                ]
    in
    Parser.parse pathParser url
        |> Maybe.withDefault NotFound


unparse : Route -> String
unparse route =
    let
        pathSegments =
            case route of
                Home ->
                    []

                Quiz id ->
                    [ "quiz", id ]

                NotFound ->
                    [ "not-found" ]

        queryParams =
            []
    in
    Url.Builder.absolute pathSegments queryParams
