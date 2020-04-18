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
          , description = "Mercedes came into the Bahrain Grand Prix after a  one-two finish in the first race in Australia, but Ferrari locked out the front-row of the grid in qualifying. Who prevailed in the island state?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "Leclerc looked set for a maiden victory only for his Ferrari to suffer a mechanical error."
          }
        , { title = "Who won the 2019 Chinese Grand Prix"
          , description = "This race marked the 1000th formula one grand prix since the very first race was held at Silversone. Bottas was leading the drivers' championship by a single point courtesy of a fastest lap point, and had the fastest lap in qualifying. But who took the chequered flag."
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Vettel", "Verstappen" ]
          , solution = Just "A third 1-2 finish in three races for Mercedes, in a race which also involved Leclerc being ordered to let his teammate through."
          }
        , { title = "Who won the 2019 Azerbaijan Grand Prix"
          , description = "Bottas once again took pole position, whilst Leclerc took fastest lap in the race and was awarded Driver of the Day, but who won the race?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Vettel", "Verstappen" ]
          , solution = Just "And a fourth one-two for the Mercedes team, but this time it was Bottas who ran from pole to flag without major incident."
          }
        , { title = "Who won the 2019 Spanish Grand Prix"
          , description = "Bottas was once again pole-sitter in Catalunya, as the Mercedes drivers appear to be doinating the early championship. Who took the chequered flag?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Verstappen", "Vettel" ]
          , solution = Just "Hamilton took first position from his teammate into turn 1. Ferrari ordered Vettel to make way for his faster teammate Leclerc, but the two switched around again later in an attempt to salvage something better than a 4-5 finish, to no avail."
          }
        , { title = "Who won the 2019 Monaco Grand Prix"
          , description = "Just how long did the Mercedes dominance stretch? They managed a 1-2 in qualifying for the Monaco grand prix, not in the race, who won?"
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Bottas", "Verstappen" ]
          , solution = Just "Hamilton won, but Bottas dropped back after the safety car caused Mercedes to have to stack their pit-stops. Verstappen finished second but was demoted behind Vettel(2nd) and Bottas(3rd) because of a 5 second penalty for an unsafe pit-stop release."
          }
        , { title = "Who won the 2019 Canadian Grand Prix"
          , description = "Ferrari look stronger here with Vettel taking pole and Leclerc 3rd behind Hamilton. Who took top spot on the podium?"
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Leclerc", "Bottas" ]
          , solution = Just "Vettel was chased by Hamilton the entire race and that saw him make a mistake following which he was deemed to have re-entered the track dangerously and forced another off the track. That gave the German a five second penalty which was enough for Hamilton to take the victory despite finishing second across the line."
          }
        , { title = "Who won the 2019 French Grand Prix"
          , description = "Back to Europe, can Vettel and Ferrari fight back after losing their appeal over the former's 5 second penalty at the Canadian grand prix?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "No. Vettel only managed 7th in qualifying, Leclerc managed 3rd in both qualifying and the race, but it was the Mercedes drivers who once again dominated with Hamilton extending his lead in the drivers' championship."
          }
        , { title = "Who won the 2019 Austrian Grand Prix"
          , description = "Would Red Bull's home track be enough to break Mercedes dominance, Leclerc takes pole in qualifying but can he convert into a much needed win for Ferrari?"
          , correct = "Verstappen"
          , alternates = [ "Leclerc", "Bottas", "Vettel" ]
          , solution = Just "Verstappen dropped from 2nd to 8th at the start off the race but fought back with the aid of a robust overtake on Leclerc that the stewards deemed legal."
          }
        , { title = "Who won the 2019 British Grand Prix"
          , description = "Finally the Mercedes dominance had been broken in Austria, but would they fight back at Silverstone?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Gasly" ]
          , solution = Just "Bottas took pole, but Hamilton the win in a relatively uneventful grand prix."
          }
        , { title = "Who won the 2019 German Grand Prix"
          , description = "Hint, this race was bonkers, approximately everyone crashed at turn 17."
          , correct = "Verstappen"
          , alternates = [ "Vettel", "Kvyat", "Stroll" ]
          , solution = Just "Lance Stroll was fourth. There were 13 finishers the tenth of which was Kubica earning Williams their only point of the season. Kudos to Haas who were the only team with two top ten finishers, bizarro world indeed."
          }
        , { title = "Who won the 2019 Hungarian Grand Prix"
          , description = "After two victories in three races Verstappen put it on pole for the Hungarian grand prix. Did he convert?"
          , correct = "Hamilton"
          , alternates = [ "Verstappen", "Vettel", "Leclerc" ]
          , solution = Just "A two stop strategy ended up winning it for Hamilton, even if it was more enforced by his brakes overheating after following Verstappen for a long time."
          }
        , { title = "Who won the 2019 Belgian Grand Prix"
          , description = "Typically a good race, the Ferraris locked out the front-row after qualifying but could they convert into a much needed win?"
          , correct = "Leclerc"
          , alternates = [ "Hamilton", "Bottas", "Vettel" ]
          , solution = Just "A race overshaddowed by the death of Anthoine Hubert, was the nonetheless an entertaining race, won by the Monegasque driver."
          }
        , { title = "Who won the 2019 Italian Grand Prix"
          , description = "Ferrari's home race, can you remember if they got a home victory? Leclerc started on pole."
          , correct = "Leclerc"
          , alternates = [ "Bottas", "Hamilton", "Ricciardo" ]
          , solution = Just "Ricciardo managed 4th in the Renault, but it was Leclerc who got his second successive win."
          }
        , { title = "Who won the 2019 Singapore Grand Prix"
          , description = "Leclerc put it on pole again, but did he make it three in a row?"
          , correct = "Vettel"
          , alternates = [ "Leclerc", "Verstappen", "Hamilton" ]
          , solution = Just "No, but Ferrari still won the race."
          }
        , { title = "Who won the 2019 Russian Grand Prix"
          , description = "Leclerc on pole again. But did convert for a win this time on the black sea coast?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "Leclerc expected to be forced to allow Vettel to pass through but a power failure for the German couldn't help Leclerc win as the Mercedes were the fastest."
          }
        , { title = "Who won the 2019 Japanese Grand Prix"
          , description = "Qualifying was moved to Sunday due to Typhoon Hagibis, that seemed to help the Ferraris who locked out the front row."
          , correct = "Bottas"
          , alternates = [ "Vettel", "Hamilton", "Albon" ]
          , solution = Just "By this time Albon was in the senior Red Bull team and secured 4th. Vettel nearly false-started and made a hash of it. Leclerc incurred two time penalties. Bottas took the victory whilst keeping a calm head."
          }
        , { title = "Who won the 2019 Mexican Grand Prix"
          , description = "Hamilton would win the world championship if he outscored his teammate by 14 points. Verstappen was on pole. Hamilton only managed 5th, but that was still two better than Bottas."
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Bottas", "Leclerc" ]
          , solution = Just "Hamilton won the race, but with Bottas 3rd he would have to wait at least another race for his 6th world championship title."
          }
        , { title = "Who won the 2019 United States Grand Prix"
          , description = "So now Bottas needs to out-score Hamilton by 22 points to keep the title alive. He does his best in qualifying with pole. But who won the race?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Verstappen", "Leclerc" ]
          , solution = Just "Bottas did everything he could, but Hamilton was second to capture his 6th world championship title."
          }
        , { title = "Who won the 2019 Brazalian Grand Prix"
          , description = "Both championships are done, so we're just racing for kudos, so who exactly got the kudos in Brazil?"
          , correct = "Verstappen"
          , alternates = [ "Gasly", "Sainz", "Raikkonen" ]
          , solution = Just "Another relatively bonkers race, with the demoted Gasly doing better in the Torro Rosso than he managed in the Red Bull managing second after Hamilton was given a penalty for taking out Albon. That also meant Carlos Sainz had his first podium."
          }
        , { title = "Who won the 2019 Abu Dhabi Grand Prix"
          , description = "Okay last race, the championship was completely done, but there were still some 3rd and 4th places to care for, who won the race?"
          , correct = "Hamilton"
          , alternates = [ "Verstappen", "Leclerc", "Bottas" ]
          , solution = Just "Probably a fitting end to the title that saw Hamilton and Mercedes dominate, whilst Verstappen and Leclerc emerge as future battlers for the title."
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
                                        Html.h3
                                            [ Picnic.success ]
                                            [ Html.text "Correct" ]

                                    False ->
                                        Html.h3
                                            [ Picnic.error ]
                                            [ Html.text "Incorrect" ]
                                , explanation
                                , next
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

                currentQuestionNum =
                    1 + List.length model.quizState.done

                totalNumQuestions =
                    currentQuestionNum + List.length model.quizState.tocome
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
                , Html.footer
                    []
                    [ Html.text "Question "
                    , currentQuestionNum |> String.fromInt |> Html.text
                    , Html.text " of "
                    , totalNumQuestions |> String.fromInt |> Html.text
                    ]
                ]
