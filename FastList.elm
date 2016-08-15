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

        [ s ] ->
            [ f s ]

        [ s, t ] ->
            [ f s, f t ]

        [ s, t, u ] ->
            [ f s, f t, f u ]

        [ s, t, u, v ] ->
            [ f s, f t, f u, f v ]

        [ s, t, u, v, w ] ->
            [ f s, f t, f u, f v, f w ]

        [ s, t, u, v, w, x ] ->
            [ f s, f t, f u, f v, f w, f x ]

        [ s, t, u, v, w, x, y ] ->
            [ f s, f t, f u, f v, f w, f x, f y ]

        s :: t :: u :: v :: w :: x :: y :: z :: tl ->
            f s
                :: f t
                :: f u
                :: f v
                :: f w
                :: f x
                :: f y
                :: f z
                :: (if ctr < 500 then
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


mapUnrolled' : (a -> b) -> List a -> List b
mapUnrolled' f xs =
    case xs of
        x :: y :: z :: w :: tl ->
            f x :: f y :: f z :: f w :: mapUnrolled f tl

        _ ->
            mapUnrolled f xs


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


mapUnrolled12 f xs =
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

        [ z, y, x, w, v, u, t, s ] ->
            [ f z, f y, f x, f w, f v, f u, f t, f s ]

        [ z, y, x, w, v, u, t, s, r ] ->
            [ f z, f y, f x, f w, f v, f u, f t, f s, f r ]

        [ z, y, x, w, v, u, t, s, r, q ] ->
            [ f z, f y, f x, f w, f v, f u, f t, f s, f r, f q ]

        [ z, y, x, w, v, u, t, s, r, q, p ] ->
            [ f z, f y, f x, f w, f v, f u, f t, f s, f r, f q, f p ]

        z :: y :: x :: w :: v :: u :: t :: s :: r :: q :: p :: o :: tl ->
            f z :: f y :: f x :: f w :: f v :: f u :: f t :: f s :: f r :: f q :: f p :: f o :: mapUnrolled12 f tl


mapTailRec : (a -> b) -> List a -> List b
mapTailRec f xs =
    let
        mapAcc f = List.foldl (\hd acc -> f hd :: acc)
    in
        mapAcc f [] xs |> reverse


mapSimple : (a -> b) -> List a -> List b
mapSimple f xs =
    case xs of
        [] ->
            []

        hd :: tl ->
            f hd :: mapSimple f tl
