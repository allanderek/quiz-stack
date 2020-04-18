module Picnic exposing
    ( card
    , error
    , success
    , warning
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes


success : Attribute msg
success =
    Attributes.class "success"


warning : Attribute msg
warning =
    Attributes.class "warning"


error : Attribute msg
error =
    Attributes.class "error"


card : List (Html msg) -> Html msg
card =
    Html.article
        [ Attributes.class "card" ]
