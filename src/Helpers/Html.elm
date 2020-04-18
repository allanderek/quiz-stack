module Helpers.Html exposing
    ( nothing
    , paragraph
    )

import Html exposing (Html)


nothing : Html msg
nothing =
    Html.text ""


paragraph : String -> Html msg
paragraph s =
    Html.p [] [ Html.text s ]
