module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Helpers.Html as Html
import Helpers.Maybe as Maybe
import Helpers.Return as Return
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import List.Extra as List
import Picnic
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
    { title : String
    , description : String
    , correct : Answer
    , alternates : List Answer
    , solution : Maybe String
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
    | TryAgain


firstQuiz : Quiz
firstQuiz =
    { name = "2019 race winners"
    , questions =
        [ { title = "Who won the 2019 Australian Grand Prix"
          , description = "The first race of the season, Ferrari were confident after a strong showing in pre-season testing, but did they convert that into a win at Albert park?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Verstappen", "Vettel" ]
          , solution = Nothing
          }
        , { title = "Who won the 2019 Bahrain Grand Prix"
          , description = ""
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "Leclerc looked set for a maiden victory only for his Ferrari to suffer a mechanical error."
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

        TryAgain ->
            { model | quizState = startQuiz model.quiz }
                |> Return.noCommand


view : Model -> Browser.Document Msg
view model =
    { title = "Title"
    , body =
        [ viewQuiz model ]
    }


viewQuiz : { a | quiz : Quiz, quizState : QuizState } -> Html Msg
viewQuiz model =
    case model.quizState.current of
        Nothing ->
            let
                correct doneQuestion =
                    doneQuestion.answer == doneQuestion.question.correct
            in
            Html.article
                [ Attributes.class "card"
                , Attributes.class "final-results"
                ]
                [ Html.header
                    []
                    [ Html.text "Chequered flag" ]
                , Html.p
                    []
                    [ Html.text "You scored: "
                    , List.count correct model.quizState.done
                        |> String.fromInt
                        |> Html.text
                    , Html.text " out of "
                    , List.length model.quizState.done |> String.fromInt |> Html.text
                    ]
                , Html.footer
                    []
                    [ Html.button
                        [ TryAgain |> Events.onClick ]
                        [ Html.text "Try again" ]
                    ]
                ]

        Just current ->
            let
                showAnswer answer =
                    let
                        correctClass =
                            case current.answered of
                                Nothing ->
                                    Attributes.class "possible"

                                Just answered ->
                                    case ( answered == answer, answer == current.question.correct ) of
                                        ( True, True ) ->
                                            Picnic.success

                                        ( False, False ) ->
                                            Attributes.class "correctly-left"

                                        ( False, True ) ->
                                            Attributes.class "incorrect-left"

                                        ( True, False ) ->
                                            Picnic.error

                        answeredClass =
                            case current.answered == Just answer of
                                False ->
                                    Attributes.class "not-selected"

                                True ->
                                    Attributes.class "selected"

                        messageAttribute =
                            case Maybe.isSomething current.answered of
                                False ->
                                    Answer answer
                                        |> Events.onClick

                                True ->
                                    Attributes.class "not-in-use"
                    in
                    Html.button
                        [ Attributes.class "answer"
                        , correctClass
                        , messageAttribute
                        , answeredClass
                        ]
                        [ Html.text answer ]

                answers =
                    List.map showAnswer (current.question.correct :: current.question.alternates)
                        |> List.map (\a -> Html.li [] [ a ])
                        |> Html.ul []

                solution =
                    let
                        explanation =
                            Html.div
                                [ Attributes.class "solution" ]
                                [ Html.text "Correct answer: "
                                , Html.text current.question.correct
                                , current.question.solution
                                    |> Maybe.withDefault ""
                                    |> Html.paragraph
                                ]
                    in
                    case current.answered of
                        Nothing ->
                            Html.nothing

                        Just answered ->
                            Html.div
                                [ Attributes.class "solution-container" ]
                                [ case answered == current.question.correct of
                                    True ->
                                        div
                                            [ Picnic.success ]
                                            [ Html.text "Correct" ]

                                    False ->
                                        div
                                            [ Picnic.error ]
                                            [ Html.text "Incorrect" ]
                                , explanation
                                ]

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
            Html.article
                [ Attributes.class "quiz-question"
                , Attributes.class "card"
                ]
                [ Html.h3
                    [ Attributes.class "question-title" ]
                    [ Html.text current.question.title ]
                    |> List.singleton
                    |> Html.header []
                , Html.paragraph current.question.description
                , Html.div
                    [ Attributes.class "answers" ]
                    [ answers ]
                , solution
                , next
                ]
