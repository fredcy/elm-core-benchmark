module Main exposing (main)

import Html
import Html.App
import Benchmark
import FastList


type alias Model =
    {}


type Msg
    = NoOp


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Benchmark.run (List.map makeSuite [ 10, 100, 1000, 10000, 100000, 1000000 ])


makeSuite : Int -> Benchmark.Suite
makeSuite size =
    let
        -- build the test data outside of the function under test so that it
        -- doesn't affect the timimg
        testdata =
            [1..size]

        fn n =
            n + 1

        testMap : () -> List Int
        testMap =
            \() -> List.map fn testdata

        testMap' : () -> List Int
        testMap' =
            \() -> FastList.map fn testdata

        testMapSimple : () -> List Int
        testMapSimple =
            \() -> FastList.mapSimple fn testdata

        testTailRec : () -> List Int
        testTailRec =
            \() -> FastList.mapTailRec fn testdata

        testUnrolled : () -> List Int
        testUnrolled =
            \() -> FastList.mapUnrolled fn testdata
    in
        Benchmark.suite ("size " ++ toString size)
            [ Benchmark.bench "original" testMap
            , Benchmark.bench "fast" testMap'
            , Benchmark.bench "naive" testMapSimple
            , Benchmark.bench "tail rec" testTailRec
            , Benchmark.bench "unrolled" testUnrolled
            ]


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.text "done"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
