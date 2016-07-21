module FastList exposing (..)

import List exposing (reverse)


map : (a -> b) -> List a -> List b
map f xs =
    mapFast f xs 0


mapFast : (a -> b) -> List a -> Int -> List b
mapFast f xs ctr =
    case xs of
        [] ->
            []

        [ x ] ->
            [ f x ]

        [ x, y ] ->
            [ f x, f y ]

        [ x, y, z ] ->
            [ f x, f y, f z ]

        x :: y :: z :: w :: tl ->
            f x
                :: f y
                :: f z
                :: f w
                :: (if ctr < 1000 then
                        mapFast f tl (ctr + 1)
                    else
                        mapTailRec f tl
                   )


mapUnrolled : (a -> b) -> List a -> List b
mapUnrolled f xs =
    case xs of
        [] ->
            []

        [ x ] ->
            [ f x ]

        [ x, y ] ->
            [ f x, f y ]

        [ x, y, z ] ->
            [ f x, f y, f z ]

        x :: y :: z :: w :: tl ->
            f x :: f y :: f z :: f w :: mapUnrolled f tl


mapTailRec : (a -> b) -> List a -> List b
mapTailRec f xs =
    let
        mapAcc f acc ys =
            case ys of
                [] ->
                    acc

                hd :: tl ->
                    mapAcc f (f hd :: acc) tl
    in
        mapAcc f [] xs |> reverse


mapSimple : (a -> b) -> List a -> List b
mapSimple f xs =
    case xs of
        [] ->
            []

        hd :: tl ->
            f hd :: mapSimple f tl
