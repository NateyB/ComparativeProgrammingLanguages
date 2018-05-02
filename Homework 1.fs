let rec Map (f : ('a -> 'b)) (lt : ('a list)) : ('b list) =
    match lt with
    |[] -> []
    |head :: tail -> (f head) :: (Map (f) tail)

let rec Filter (f : ('a -> bool)) (lt : ('a list)) : ('a list) =
    match lt with
    | [] -> []
    | head :: tail when (f head) -> head :: (Filter (f) tail)
    | head :: tail -> Filter (f) tail

(*
Sample inputs/outputs.

val Map : f:('a -> 'b) -> lt:'a list -> 'b list
val Filter : f:('a -> bool) -> lt:'a list -> 'a list

> Map (fun x -> x * 2) [1;2;3;4;5];;
val it : int list = [2; 4; 6; 8; 10]

> let MapWithF = Map (fun x -> x * 2);;

val MapWithF : (int list -> int list)

> MapWithF [1;2;3;4;5];;
val it : int list = [2; 4; 6; 8; 10]

> Filter (fun x -> x % 2 = 0) [1;2;3;4;5];;
val it : int list = [2; 4]

> let FilterWithF = Filter (fun x -> x % 2 = 0);;

val FilterWithF : (int list -> int list)

> FilterWithF [1;2;3;4;5];;
val it : int list = [2; 4]


Edge case tests:
> FilterWithF [];;
val it : int list = []

> MapWithF [];;
val it : int list = []

> FilterWithF [3];;
val it : int list = []

> MapWithF [3];;
val it : int list = [6]

All edge tests passed. Yay.

*)
