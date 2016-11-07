port module Main exposing (main)

import Html exposing (Html)
import Html.App
import String
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
    | Error Benchmark.ErrorInfo


type alias ChartDatum =
    { size : Int
    , name : String
    , elmtspersec : Float
    }


{-| Send results to d3.js charting code
-}
port chart : List ChartDatum -> Cmd msg


{-| Extract size from suite name. E.g. "suite 17" -> 17
-}
sizeFromSuitename : String -> Int
sizeFromSuitename name =
    let
        words =
            String.split " " name

        size =
            case words of
                [ _, sizeStr ] ->
                    String.toInt sizeStr |> Result.withDefault 0

                _ ->
                    0
    in
        size


{-| Convert benchmark results to format expected by the JS code doing the
charting. Ignore those with samples == 0 as they are error cases.
-}
chartFromResults : List Benchmark.Result -> List ChartDatum
chartFromResults results =
    let
        convert { suite, benchmark, samples } =
            if samples == [] then
                Nothing
            else
                let
                    stats =
                        Benchmark.getStats samples

                    freq =
                        1 / stats.mean

                    size =
                        sizeFromSuitename suite
                in
                    Just
                        { size = size
                        , name = benchmark
                        , elmtspersec = toFloat size * freq
                        }
    in
        List.filterMap convert results


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
    , Task.perform (\_ -> Debug.crash "runTask failed") Started (Benchmark.runTask (List.map makeSuite sizes))
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Event event ->
            case event of
                Benchmark.Start { platform } ->
                    { model | platform = Just platform } ! []

                Benchmark.Cycle result ->
                    let
                        resultsNew =
                            model.results ++ [ result ]
                    in
                        { model | results = resultsNew } ! [ chart (chartFromResults resultsNew) ]

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
        [ viewStatus model.done
        , Html.h2 [] [ Html.text "results" ]
        , viewResults model.results
        , viewErrors model.errors
        ]


viewResults : List Benchmark.Result -> Html Msg
viewResults results =
    let
        viewResult result =
            if result.samples /= [] then
                Html.li [] [ Html.text (toString result) ]
            else
                -- if a benchmark errors out it will report 0 samples
                Html.text ""
    in
        Html.ul [] (List.map viewResult results)


viewErrors : List Benchmark.ErrorInfo -> Html Msg
viewErrors errors =
    let
        viewError error =
            Html.li [] [ Html.text (toString error) ]
    in
        if List.length errors > 0 then
            Html.div []
                [ Html.h2 [] [ Html.text "errors" ]
                , Html.ul [] (List.map viewError errors)
                ]
        else
            Html.text ""


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
    --[0..10] |> List.map ((^) 4)
    --[0..16] |> List.map ((^) 2)
    makeSizes 1.9 1000000


makeSizes base atLeast =
    let
        make n acc =
            let
                v =
                    round (base ^ n)
            in
                if v >= atLeast then
                    List.reverse (v :: acc)
                else
                    make (n + 1) (v :: acc)
    in
        make 0 []


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
                { defaults | maxTime = 5 }
    in
        Benchmark.suiteWithOptions options
            ("size " ++ toString size)
            (List.map (\( n, t ) -> makeBench n t) basicAlternatives)


type alias MapFn =
    (Int -> Int) -> List Int -> List Int


basicAlternatives : List ( String, MapFn )
basicAlternatives =
    [ ( "original", List.map )
    , ( "fast", FastList.map )
    , ( "naive", FastList.mapSimple )
    , ( "tail rec", FastList.mapTailRec )
    , ( "unrolled8", FastList.mapUnrolled8 )
    ]


unrolledAlternatives : List ( String, MapFn )
unrolledAlternatives =
    [ ( "simple", FastList.mapSimple )
    , ( "unrolled2", FastList.mapUnrolled2 )
    , ( "unrolled4", FastList.mapUnrolled )
    , ( "unrolled8", FastList.mapUnrolled8 )
    , ( "unrolled12", FastList.mapUnrolled12 )
    ]


mapTailRecAlternatives : List ( String, MapFn )
mapTailRecAlternatives =
    [ ( "map foldl", FastList.mapTailRec )
    , ( "map simple", FastList.mapTailRec' )
    ]
