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


mapUnrolled2 : (a -> b) -> List a -> List b
mapUnrolled2 f xs =
    case xs of
        [] ->
            []

        [ x ] ->
            [ f x ]

        x :: y :: tl ->
            f x :: f y :: mapUnrolled2 f tl


mapUnrolled8 f xs =
    case xs of
        [] ->
            []

        [ z ] ->
            [ f z ]

        [ z, y ] ->
            [ f z, f y ]

        [ z, y, x ] ->
            [ f z, f y, f x ]

        [ z, y, x, w ] ->
            [ f z, f y, f x, f w ]

        [ z, y, x, w, v ] ->
            [ f z, f y, f x, f w, f v ]

        [ z, y, x, w, v, u ] ->
            [ f z, f y, f x, f w, f v, f u ]

        [ z, y, x, w, v, u, t ] ->
            [ f z, f y, f x, f w, f v, f u, f t ]

        z :: y :: x :: w :: v :: u :: t :: s :: tl ->
            f z :: f y :: f x :: f w :: f v :: f u :: f t :: f s :: mapUnrolled8 f tl


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
