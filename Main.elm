module Main exposing (main)

import Html
import Html.App
import Benchmark
import FastList


type alias Model =
    {}


main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ () -> ()
        , view = \() -> Html.text "Done."
        }
        |> Benchmark.run (List.map makeSuite [ 10, 100, 1000, 10000, 100000, 1000000 ])


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
    in
        Benchmark.suite ("size " ++ toString size)
            [ makeBench "original" List.map
            , makeBench "fast" FastList.map
            , makeBench "naive" FastList.mapSimple
            , makeBench "tail rec" FastList.mapTailRec
            , makeBench "unrolled" FastList.mapUnrolled
            ]
