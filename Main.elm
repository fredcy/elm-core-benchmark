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
        |> Benchmark.run
            [ makeSuite 10
            , makeSuite 100
            , makeSuite 10000
            , makeSuite 1000000
              --, makeSuite 10000000
            ]


makeSuite : Int -> Benchmark.Suite
makeSuite size =
    let
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
    in
        Benchmark.suite ("size " ++ toString size)
            [ Benchmark.bench "map" testMap
            , Benchmark.bench "map'" testMap'
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
