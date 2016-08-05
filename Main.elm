module Main exposing (main)

import Html exposing (Html)
import Html.App
import Task
import Benchmark
import FastList


type alias Model =
    { results : List Benchmark.Result
    , errors : List Benchmark.ErrorInfo
    , platform : Maybe String
    , done : Bool
    }


type Msg
    = Started ()
    | Event Benchmark.Event
    | Error Benchmark.Error


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always (Benchmark.events Event)
        }


init : ( Model, Cmd Msg )
init =
    ( Model [] [] Nothing False
    , Task.perform Error Started (Benchmark.runTask (List.map makeSuite sizes))
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Event event ->
            case event of
                Benchmark.Start { platform } ->
                    { model | platform = Just platform } ! []

                Benchmark.Cycle result ->
                    { model | results = model.results ++ [ result ] } ! []

                Benchmark.Complete result ->
                    model ! []

                Benchmark.Finished ->
                    { model | done = True } ! []

                Benchmark.BenchError error ->
                    { model | errors = model.errors ++ [ error ] } ! []

        _ ->
            model ! []


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h2 [] [ Html.text "results" ]
        , viewResults model.results
        , Html.h2 [] [ Html.text "errors" ]
        , viewErrors model.errors
        , viewStatus model.done
        ]


viewResults : List Benchmark.Result -> Html Msg
viewResults results =
    let
        viewResult result =
            if result.samples > 0 then
                Html.li [] [ Html.text (toString result) ]
            else
                Html.text ""
    in
        Html.ul [] (List.map viewResult results)


viewErrors : List Benchmark.ErrorInfo -> Html Msg
viewErrors errors =
    let
        viewError error =
            Html.li [] [ Html.text (toString error) ]
    in
        Html.ul [] (List.map viewError errors)


viewStatus : Bool -> Html Msg
viewStatus done =
    Html.p []
        [ Html.text
            (if done then
                "done"
             else
                "running ..."
            )
        ]


sizes : List Int
sizes =
    [0..10] |> List.map ((^) 4)


makeSuite : Int -> Benchmark.Suite
makeSuite size =
    let
        -- build the test data outside of the function under test so that it
        -- doesn't affect the timimg
        testdata =
            [1..size]

        mapFn =
            ((+) 1)

        makeBench name testFn =
            Benchmark.bench name (\() -> testFn mapFn testdata)

        options =
            let
                defaults =
                    Benchmark.defaultOptions
            in
                { defaults | maxTime = 10 }
    in
        Benchmark.suiteWithOptions options
            ("size " ++ toString size)
            [ makeBench "original" List.map
            , makeBench "fast" FastList.map
            , makeBench "naive" FastList.mapSimple
            , makeBench "tail rec" FastList.mapTailRec
            , makeBench "unrolled" FastList.mapUnrolled
            ]
