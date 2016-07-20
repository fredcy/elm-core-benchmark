module Main exposing (main)

import Html
import Html.App
import Benchmark


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
        |> Benchmark.run [ mapSuite ]


mapSuite : Benchmark.Suite
mapSuite =
    Benchmark.suite "map"
        [ Benchmark.bench "map" testMap ]


testdata =
    [1..10000]


testMap : () -> List Int
testMap =
    \() -> List.map ((+) 1) testdata


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
