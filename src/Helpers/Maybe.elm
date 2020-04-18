module Helpers.Maybe exposing (isSomething)


isSomething : Maybe a -> Bool
isSomething mA =
    mA /= Nothing
