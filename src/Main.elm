module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Helpers.Html as Html
import Helpers.Maybe as Maybe
import Helpers.Return as Return
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Url


main : Program ProgramFlags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions =
    always Sub.none


type alias ProgramFlags =
    ()


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , quiz : Quiz
    , quizState : QuizState
    }


type alias Quiz =
    { name : String
    , questions : List Question
    }


type alias Question =
    { description : String
    , correct : Answer
    , alternates : List Answer
    }


type alias Answer =
    String


type alias QuizState =
    { done : List { answer : Answer, question : Question }
    , current : Maybe { question : Question, answered : Maybe String }
    , tocome : List Question
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Answer String
    | NextQuestion


firstQuiz : Quiz
firstQuiz =
    { name = "2019 race winners"
    , questions =
        [ { description = "Who won the 2019 Australian Grand Prix"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Verstappen", "Vettel" ]
          }
        , { description = "Who won the 2019 Bahrain Grand Prix"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          }
        ]
    }


startQuiz : Quiz -> QuizState
startQuiz quiz =
    case quiz.questions of
        [] ->
            { done = []
            , current = Nothing
            , tocome = []
            }

        first :: rest ->
            { done = []
            , current = Just { question = first, answered = Nothing }
            , tocome = rest
            }


init : ProgramFlags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    let
        initialModel =
            { key = key
            , url = url
            , quiz = firstQuiz
            , quizState = startQuiz firstQuiz
            }
    in
    Return.noCommand initialModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            let
                command =
                    case urlRequest of
                        Browser.Internal url ->
                            Nav.pushUrl model.key <| Url.toString url

                        Browser.External href ->
                            Nav.load href
            in
            Return.withCommand command model

        UrlChanged url ->
            Return.noCommand { model | url = url }

        Answer answer ->
            case model.quizState.current of
                Nothing ->
                    -- Strange, bit of an error
                    Return.noCommand model

                Just current ->
                    let
                        newCurrent =
                            { current | answered = Just answer }

                        quizState =
                            model.quizState

                        newQuizState =
                            { quizState | current = Just newCurrent }
                    in
                    { model | quizState = newQuizState }
                        |> Return.noCommand

        NextQuestion ->
            let
                quizState =
                    model.quizState

                newDone =
                    case quizState.current of
                        Nothing ->
                            -- Strange.
                            quizState.done

                        Just current ->
                            [ { question = current.question
                              , answer = current.answered |> Maybe.withDefault ""
                              }
                            ]
                                |> (++) quizState.done

                newQuizState =
                    case quizState.tocome of
                        [] ->
                            { quizState
                                | done = newDone
                                , current = Nothing
                            }

                        first :: rest ->
                            { quizState
                                | done = newDone
                                , current = Just { question = first, answered = Nothing }
                                , tocome = rest
                            }
            in
            { model | quizState = newQuizState }
                |> Return.noCommand


view : Model -> Browser.Document Msg
view model =
    { title = "Title"
    , body =
        [ viewQuiz model ]
    }


paragraph : String -> Html msg
paragraph s =
    Html.p [] [ Html.text s ]


viewQuiz : { a | quiz : Quiz, quizState : QuizState } -> Html Msg
viewQuiz model =
    case model.quizState.current of
        Nothing ->
            Html.text "You are at the end of the quiz"

        Just current ->
            let
                showAnswer answer =
                    let
                        correctClass =
                            case current.answered of
                                Nothing ->
                                    "possible"

                                Just answered ->
                                    case ( answered == answer, answer == current.question.correct ) of
                                        ( True, True ) ->
                                            "correct"

                                        ( False, False ) ->
                                            "correctly-left"

                                        ( False, True ) ->
                                            "incorrect-left"

                                        ( True, False ) ->
                                            "incorrect"

                        messageAttribute =
                            case Maybe.isSomething current.answered of
                                False ->
                                    Answer answer
                                        |> Events.onClick

                                True ->
                                    Attributes.disabled True
                    in
                    Html.button
                        [ Attributes.class correctClass
                        , messageAttribute
                        ]
                        [ Html.text answer ]

                answers =
                    List.map showAnswer (current.question.correct :: current.question.alternates)
                        |> List.map (\a -> Html.li [] [ a ])
                        |> Html.ul []

                next =
                    case current.answered of
                        Nothing ->
                            Html.nothing

                        Just _ ->
                            Html.button
                                [ Attributes.class "next-button"
                                , Events.onClick NextQuestion
                                ]
                                [ Html.text "Next" ]
            in
            Html.div
                [ Attributes.class "quiz-question" ]
                [ paragraph current.question.description
                , Html.div
                    [ Attributes.class "answers" ]
                    [ answers ]
                , next
                ]
