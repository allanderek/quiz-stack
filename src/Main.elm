module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Helpers.Html as Html
import Helpers.Maybe as Maybe
import Helpers.Return as Return
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import List.Extra as List
import Picnic
import Random
import Random.List as Random
import Route exposing (Route)
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
    Decode.Value


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , seed : Random.Seed
    , route : Route
    , quizzes : List Quiz
    , quizStates : Dict QuizId QuizState
    }


type alias Quiz =
    QuizData { order : List Answer }


type alias QuizData a =
    { name : QuizName
    , id : QuizId
    , introduction : List String
    , questions : List (Question a)
    }


type alias QuizName =
    String


type alias QuizId =
    String


type alias Question a =
    { a
        | title : QuizName
        , image : Maybe String
        , description : String
        , correct : Answer
        , alternates : List Answer
        , solution : Maybe String
    }


type alias Answer =
    String


type alias QuizState =
    { current : Int
    , answers : Dict Int Answer
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | StartQuiz QuizId
    | Answer QuizId String
    | NextQuestion QuizId
    | GiveUp QuizId
    | TryAgain QuizId


firstQuiz : QuizData {}
firstQuiz =
    { name = "2019 race winners"
    , id = "race-winners-2019"
    , introduction =
        [ "Let's see how much you remember from the 2019 season."
        , "For each of the 21 races of the season, all you have to remember is who won the race."
        , "Each question will feature the four drivers that finished 1-4th."
        ]
    , questions =
        [ { title = "Who won the 2019 Australian Grand Prix"
          , image = Nothing
          , description = "The first race of the season, Ferrari were confident after a strong showing in pre-season testing, but did they convert that into a win at Albert park?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Verstappen", "Vettel" ]
          , solution = Nothing
          }
        , { title = "Who won the 2019 Bahrain Grand Prix"
          , image = Nothing
          , description = "Mercedes came into the Bahrain Grand Prix after a  one-two finish in the first race in Australia, but Ferrari locked out the front-row of the grid in qualifying. Who prevailed in the island state?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "Leclerc looked set for a maiden victory only for his Ferrari to suffer a mechanical error."
          }
        , { title = "Who won the 2019 Chinese Grand Prix"
          , image = Nothing
          , description = "This race marked the 1000th formula one grand prix since the very first race was held at Silversone. Bottas was leading the drivers' championship by a single point courtesy of a fastest lap point, and had the fastest lap in qualifying. But who took the chequered flag."
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Vettel", "Verstappen" ]
          , solution = Just "A third 1-2 finish in three races for Mercedes, in a race which also involved Leclerc being ordered to let his teammate through."
          }
        , { title = "Who won the 2019 Azerbaijan Grand Prix"
          , image = Nothing
          , description = "Bottas once again took pole position, whilst Leclerc took fastest lap in the race and was awarded Driver of the Day, but who won the race?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Vettel", "Verstappen" ]
          , solution = Just "And a fourth one-two for the Mercedes team, but this time it was Bottas who ran from pole to flag without major incident."
          }
        , { title = "Who won the 2019 Spanish Grand Prix"
          , image = Nothing
          , description = "Bottas was once again pole-sitter in Catalunya, as the Mercedes drivers appear to be dominating the early championship. Who took the chequered flag?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Verstappen", "Vettel" ]
          , solution = Just "Hamilton took first position from his teammate into turn 1. Ferrari ordered Vettel to make way for his faster teammate Leclerc, but the two switched around again later in an attempt to salvage something better than a 4-5 finish, to no avail."
          }
        , { title = "Who won the 2019 Monaco Grand Prix"
          , image = Nothing
          , description = "Just how long did the Mercedes dominance stretch? They managed a 1-2 in qualifying for the Monaco grand prix, not in the race, who won?"
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Bottas", "Verstappen" ]
          , solution = Just "Hamilton won, but Bottas dropped back after the safety car caused Mercedes to have to stack their pit-stops. Verstappen finished second but was demoted behind Vettel(2nd) and Bottas(3rd) because of a 5 second penalty for an unsafe pit-stop release."
          }
        , { title = "Who won the 2019 Canadian Grand Prix"
          , image = Nothing
          , description = "Ferrari look stronger here with Vettel taking pole and Leclerc 3rd behind Hamilton. Who took top spot on the podium?"
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Leclerc", "Bottas" ]
          , solution = Just "Vettel was chased by Hamilton the entire race and that saw him make a mistake following which he was deemed to have re-entered the track dangerously and forced another off the track. That gave the German a five second penalty which was enough for Hamilton to take the victory despite finishing second across the line."
          }
        , { title = "Who won the 2019 French Grand Prix"
          , image = Nothing
          , description = "Back to Europe, can Vettel and Ferrari fight back after losing their appeal over the former's 5 second penalty at the Canadian grand prix?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "No. Vettel only managed 7th in qualifying, Leclerc managed 3rd in both qualifying and the race, but it was the Mercedes drivers who once again dominated with Hamilton extending his lead in the drivers' championship."
          }
        , { title = "Who won the 2019 Austrian Grand Prix"
          , image = Nothing
          , description = "Would Red Bull's home track be enough to break Mercedes dominance, Leclerc takes pole in qualifying but can he convert into a much needed win for Ferrari?"
          , correct = "Verstappen"
          , alternates = [ "Leclerc", "Bottas", "Vettel" ]
          , solution = Just "Verstappen dropped from 2nd to 8th at the start off the race but fought back with the aid of a robust overtake on Leclerc that the stewards deemed legal."
          }
        , { title = "Who won the 2019 British Grand Prix"
          , image = Nothing
          , description = "Finally the Mercedes dominance had been broken in Austria, but would they fight back at Silverstone?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Gasly" ]
          , solution = Just "Bottas took pole, but Hamilton the win in a relatively uneventful grand prix."
          }
        , { title = "Who won the 2019 German Grand Prix"
          , image = Nothing
          , description = "Hint, this race was bonkers, approximately everyone crashed at turn 17."
          , correct = "Verstappen"
          , alternates = [ "Vettel", "Kvyat", "Stroll" ]
          , solution = Just "Lance Stroll was fourth. There were 13 finishers the tenth of which was Kubica earning Williams their only point of the season. Kudos to Haas who were the only team with two top ten finishers, bizarro world indeed."
          }
        , { title = "Who won the 2019 Hungarian Grand Prix"
          , image = Nothing
          , description = "After two victories in three races Verstappen put it on pole for the Hungarian grand prix. Did he convert?"
          , correct = "Hamilton"
          , alternates = [ "Verstappen", "Vettel", "Leclerc" ]
          , solution = Just "A two stop strategy ended up winning it for Hamilton, even if it was more enforced by his brakes overheating after following Verstappen for a long time."
          }
        , { title = "Who won the 2019 Belgian Grand Prix"
          , image = Nothing
          , description = "Typically a good race, the Ferraris locked out the front-row after qualifying but could they convert into a much needed win?"
          , correct = "Leclerc"
          , alternates = [ "Hamilton", "Bottas", "Vettel" ]
          , solution = Just "A race overshaddowed by the death of Anthoine Hubert, was the nonetheless an entertaining race, won by the Monegasque driver."
          }
        , { title = "Who won the 2019 Italian Grand Prix"
          , image = Nothing
          , description = "Ferrari's home race, can you remember if they got a home victory? Leclerc started on pole."
          , correct = "Leclerc"
          , alternates = [ "Bottas", "Hamilton", "Ricciardo" ]
          , solution = Just "Ricciardo managed 4th in the Renault, but it was Leclerc who got his second successive win."
          }
        , { title = "Who won the 2019 Singapore Grand Prix"
          , image = Nothing
          , description = "Leclerc put it on pole again, but did he make it three in a row?"
          , correct = "Vettel"
          , alternates = [ "Leclerc", "Verstappen", "Hamilton" ]
          , solution = Just "No, but Ferrari still won the race."
          }
        , { title = "Who won the 2019 Russian Grand Prix"
          , image = Nothing
          , description = "Leclerc on pole again. But did he convert for a win this time on the black sea coast?"
          , correct = "Hamilton"
          , alternates = [ "Bottas", "Leclerc", "Verstappen" ]
          , solution = Just "Leclerc expected to be forced to allow Vettel to pass through but a power failure for the German couldn't help Leclerc win as the Mercedes were the fastest."
          }
        , { title = "Who won the 2019 Japanese Grand Prix"
          , image = Nothing
          , description = "Qualifying was moved to Sunday due to Typhoon Hagibis, that seemed to help the Ferraris who locked out the front row."
          , correct = "Bottas"
          , alternates = [ "Vettel", "Hamilton", "Albon" ]
          , solution = Just "By this time Albon was in the senior Red Bull team and secured 4th. Vettel nearly false-started and made a hash of it. Leclerc incurred two time penalties. Bottas took the victory whilst keeping a calm head."
          }
        , { title = "Who won the 2019 Mexican Grand Prix"
          , image = Nothing
          , description = "Hamilton would win the world championship if he outscored his teammate by 14 points. Verstappen was on pole. Hamilton only managed 5th, but that was still two better than Bottas."
          , correct = "Hamilton"
          , alternates = [ "Vettel", "Bottas", "Leclerc" ]
          , solution = Just "Hamilton won the race, but with Bottas 3rd he would have to wait at least another race for his 6th world championship title."
          }
        , { title = "Who won the 2019 United States Grand Prix"
          , image = Nothing
          , description = "So now Bottas needs to out-score Hamilton by 22 points to keep the title alive. He does his best in qualifying with pole. But who won the race?"
          , correct = "Bottas"
          , alternates = [ "Hamilton", "Verstappen", "Leclerc" ]
          , solution = Just "Bottas did everything he could, but Hamilton was second to capture his 6th world championship title."
          }
        , { title = "Who won the 2019 Brazalian Grand Prix"
          , image = Nothing
          , description = "Both championships are done, so we're just racing for kudos, so who exactly got the kudos in Brazil?"
          , correct = "Verstappen"
          , alternates = [ "Gasly", "Sainz", "Raikkonen" ]
          , solution = Just "Another relatively bonkers race, with the demoted Gasly doing better in the Torro Rosso than he managed in the Red Bull managing second after Hamilton was given a penalty for taking out Albon. That also meant Carlos Sainz had his first podium."
          }
        , { title = "Who won the 2019 Abu Dhabi Grand Prix"
          , image = Nothing
          , description = "Okay last race, the championship was completely done, but there were still some 3rd and 4th places to care for, who won the race?"
          , correct = "Hamilton"
          , alternates = [ "Verstappen", "Leclerc", "Bottas" ]
          , solution = Just "Probably a fitting end to the title that saw Hamilton and Mercedes dominate, whilst Verstappen and Leclerc emerge as future battlers for the title."
          }
        ]
    }


tracksQuiz : QuizData {}
tracksQuiz =
    { name = "Race tracks"
    , id = "race-tracks"
    , introduction =
        [ "I'm going to show you schematic diagrams of race tracks just name the track. Easy."
        ]
    , questions =
        [ { title = "Where is this track"
          , image = Just "https://upload.wikimedia.org/wikipedia/commons/3/36/Monte_Carlo_Formula_1_track_map.svg"
          , description = ""
          , correct = "Monaco"
          , alternates = [ "Monza", "Montreal", "Paul Ricard" ]
          , solution = Nothing
          }
        ]
    }


randomiseListElements : (Random.Seed -> a -> ( Random.Seed, b )) -> Random.Seed -> List a -> ( Random.Seed, List b )
randomiseListElements randomiseElement initialSeed elements =
    let
        processElement element ( currentSeed, currentElements ) =
            let
                ( newSeed, newElement ) =
                    randomiseElement currentSeed element
            in
            ( newSeed, newElement :: currentElements )
    in
    List.foldr processElement ( initialSeed, [] ) elements


setAnswersQuiz : Random.Seed -> QuizData a -> ( Random.Seed, Quiz )
setAnswersQuiz initialSeed quizData =
    let
        setAnswersQuestion question ( currentSeed, questions ) =
            let
                generator =
                    question.correct
                        :: question.alternates
                        |> Random.shuffle

                ( answers, newCurrentSeed ) =
                    Random.step generator currentSeed
            in
            ( newCurrentSeed
            , { title = question.title
              , image = question.image
              , description = question.description
              , correct = question.correct
              , alternates = question.alternates
              , solution = question.solution
              , order = answers
              }
                :: questions
            )

        ( newSeed, newQuestions ) =
            List.foldr setAnswersQuestion ( initialSeed, [] ) quizData.questions
    in
    ( newSeed
    , { name = quizData.name
      , id = quizData.id
      , introduction = quizData.introduction
      , questions = newQuestions
      }
    )


init : ProgramFlags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init programFlags url key =
    let
        seed =
            Decode.decodeValue (Decode.field "dateTimeNow" Decode.int) programFlags
                |> Result.withDefault 12345
                |> Random.initialSeed

        rawQuizzes =
            [ firstQuiz
            , tracksQuiz
            ]

        ( newSeed, quizzes ) =
            randomiseListElements setAnswersQuiz seed rawQuizzes

        initialModel =
            { key = key
            , url = url
            , seed = newSeed
            , route = Route.parse url
            , quizzes = quizzes
            , quizStates = Dict.empty
            }
    in
    Return.noCommand initialModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        emptyQuizState =
            { current = 0, answers = Dict.empty }
    in
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
            let
                route =
                    Route.parse url
            in
            { model
                | url = url
                , route = route
            }
                |> Return.noCommand

        StartQuiz quizId ->
            { model | quizStates = Dict.insert quizId emptyQuizState model.quizStates }
                |> Return.noCommand

        GiveUp quizId ->
            let
                oldQuizState =
                    Dict.get quizId model.quizStates
                        |> Maybe.withDefault emptyQuizState

                newQuizState =
                    { oldQuizState | current = -1 }
            in
            { model | quizStates = Dict.insert quizId newQuizState model.quizStates }
                |> Return.noCommand

        Answer quizId answer ->
            let
                oldQuizState =
                    Dict.get quizId model.quizStates
                        |> Maybe.withDefault emptyQuizState

                newQuizState =
                    { oldQuizState | answers = Dict.insert oldQuizState.current answer oldQuizState.answers }
            in
            { model | quizStates = Dict.insert quizId newQuizState model.quizStates }
                |> Return.noCommand

        NextQuestion quizId ->
            let
                oldQuizState =
                    Dict.get quizId model.quizStates
                        |> Maybe.withDefault emptyQuizState

                newQuizState =
                    { oldQuizState | current = oldQuizState.current + 1 }
            in
            { model | quizStates = Dict.insert quizId newQuizState model.quizStates }
                |> Return.noCommand

        TryAgain quizId ->
            { model | quizStates = Dict.insert quizId emptyQuizState model.quizStates }
                |> Return.noCommand


view : Model -> Browser.Document Msg
view model =
    { title = "Title"
    , body =
        case model.route of
            Route.Home ->
                [ viewHome model ]

            Route.Quiz quizId ->
                [ viewQuiz model quizId ]

            Route.NotFound ->
                [ Html.text "I'm sorry, I am not the page you were looking for." ]
    }


viewHome : Model -> Html Msg
viewHome model =
    let
        showQuizLink quiz =
            Html.a
                [ Route.Quiz quiz.id
                    |> Route.href
                ]
                [ quiz.name |> Html.text ]

        content =
            List.map showQuizLink model.quizzes
                |> List.map (List.singleton >> Html.li [])
                |> Html.ol []
    in
    Html.article
        [ Attributes.class "card"
        , Attributes.class "quiz-list"
        ]
        [ content ]


viewHomeLink : Html msg
viewHomeLink =
    Html.a
        [ Attributes.class "home-button"
        , Route.Home |> Route.href
        ]
        [ Html.text "Home" ]


viewQuiz : Model -> QuizId -> Html Msg
viewQuiz model quizId =
    case List.find (\q -> q.id == quizId) model.quizzes of
        Nothing ->
            Html.text "Sorry I could not find that quiz."

        Just quiz ->
            case Dict.get quizId model.quizStates of
                Nothing ->
                    Html.article
                        [ Attributes.class "card"
                        , Attributes.class "introduction"
                        ]
                        [ Html.header
                            []
                            [ Html.text "Lights out" ]
                        , quiz.introduction
                            |> List.map Html.paragraph
                            |> Html.section []
                        , Html.div
                            [ Attributes.class "actions" ]
                            [ Html.button
                                [ Attributes.class "start-button"
                                , StartQuiz quizId |> Events.onClick
                                ]
                                [ Html.text "Start" ]
                            , viewHomeLink
                            ]
                        ]

                Just state ->
                    case List.getAt state.current quiz.questions of
                        Nothing ->
                            -- Then we must have reached the end of the quiz.
                            let
                                correct index doneQuestion =
                                    Dict.get index state.answers == Just doneQuestion.correct
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
                                    , List.indexedMap correct quiz.questions
                                        |> List.count identity
                                        |> String.fromInt
                                        |> Html.text
                                    , Html.text " out of "
                                    , List.length quiz.questions |> String.fromInt |> Html.text
                                    ]
                                , Html.div
                                    [ Attributes.class "actions" ]
                                    [ Html.button
                                        [ Attributes.class "try-again-button"
                                        , TryAgain quizId |> Events.onClick
                                        ]
                                        [ Html.text "Try again" ]
                                    , viewHomeLink
                                    ]
                                ]

                        Just current ->
                            let
                                currentAnswer =
                                    Dict.get state.current state.answers

                                showAnswer answer =
                                    let
                                        correctClass =
                                            case currentAnswer of
                                                Nothing ->
                                                    Attributes.class "possible"

                                                Just answered ->
                                                    case ( answered == answer, answer == current.correct ) of
                                                        ( True, True ) ->
                                                            Picnic.success

                                                        ( False, False ) ->
                                                            Attributes.class "correctly-left"

                                                        ( False, True ) ->
                                                            Attributes.class "incorrect-left"

                                                        ( True, False ) ->
                                                            Picnic.error

                                        answeredClass =
                                            case currentAnswer == Just answer of
                                                False ->
                                                    Attributes.class "not-selected"

                                                True ->
                                                    Attributes.class "selected"

                                        messageAttribute =
                                            case Maybe.isSomething currentAnswer of
                                                False ->
                                                    Answer quizId answer
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
                                    List.map showAnswer current.order
                                        |> List.map (\a -> Html.li [] [ a ])
                                        |> Html.ul []

                                solution =
                                    let
                                        explanation =
                                            Html.div
                                                [ Attributes.class "solution" ]
                                                [ Html.text "Correct answer: "
                                                , Html.text current.correct
                                                , current.solution
                                                    |> Maybe.withDefault ""
                                                    |> Html.paragraph
                                                ]
                                    in
                                    case currentAnswer of
                                        Nothing ->
                                            Html.nothing

                                        Just answered ->
                                            Html.div
                                                [ Attributes.class "solution-container" ]
                                                [ case answered == current.correct of
                                                    True ->
                                                        Html.h3
                                                            [ Picnic.success ]
                                                            [ Html.text "Correct" ]

                                                    False ->
                                                        Html.h3
                                                            [ Picnic.error ]
                                                            [ Html.text "Incorrect" ]
                                                , explanation
                                                ]

                                actions =
                                    div
                                        [ Attributes.class "actions" ]
                                        [ case Maybe.isSomething currentAnswer of
                                            True ->
                                                next

                                            False ->
                                                Html.nothing
                                        , giveUp
                                        ]

                                next =
                                    Html.button
                                        [ Attributes.class "next-button"
                                        , NextQuestion quizId
                                            |> Events.onClick
                                        ]
                                        [ Html.text "Next" ]

                                giveUp =
                                    Html.button
                                        [ Attributes.class "giveup-button"
                                        , Picnic.error
                                        , GiveUp quizId
                                            |> Events.onClick
                                        ]
                                        [ Html.text "Give up" ]

                                currentQuestionNum =
                                    1 + Dict.size state.answers

                                totalNumQuestions =
                                    currentQuestionNum + List.length quiz.questions
                            in
                            Html.article
                                [ Attributes.class "quiz-question"
                                , Attributes.class "card"
                                ]
                                [ Html.h3
                                    [ Attributes.class "question-title" ]
                                    [ Html.text current.title ]
                                    |> List.singleton
                                    |> Html.header []
                                , case current.image of
                                    Nothing ->
                                        Html.nothing

                                    Just image ->
                                        Html.img
                                            [ Attributes.src image ]
                                            []
                                , Html.paragraph current.description
                                , Html.div
                                    [ Attributes.class "answers" ]
                                    [ answers ]
                                , solution
                                , actions
                                , Html.footer
                                    []
                                    [ Html.text "Question "
                                    , currentQuestionNum |> String.fromInt |> Html.text
                                    , Html.text " of "
                                    , totalNumQuestions |> String.fromInt |> Html.text
                                    ]
                                ]
