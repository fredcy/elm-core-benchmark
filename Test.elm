module Test exposing (main)

import ElmTest exposing (Test, Assertion, assert, assertEqual, test, suite, runSuiteHtml)
import FastList exposing (..)


main : Program Never
main =
    runSuiteHtml <| ElmTest.suite "all" suites


suites : List ElmTest.Test
suites =
    [0..16] ++ ([5..16] |> List.map ((^) 2)) |> List.map suiteSize


suiteSize : Int -> ElmTest.Test
suiteSize size =
    let
        data =
            [1..size]

        fn =
            (*) 7

        expected =
            List.map fn data

        makeTest name mapFn =
            test name (assertEqual expected (mapFn fn data))
    in
        suite ("size " ++ toString size)
            ([ makeTest "fast" FastList.map
             , makeTest "tail rec" FastList.mapTailRec
             ]
                ++ if (size < 5000) then
                    [ makeTest "unrolled 4" FastList.mapUnrolled
                    , makeTest "unrolled 8" FastList.mapUnrolled8
                    , makeTest "unrolled 12" FastList.mapUnrolled12
                    , makeTest "naive" FastList.mapSimple
                    ]
                   else
                    []
            )
