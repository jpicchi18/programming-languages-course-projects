type mygrammar_nonterminals = 
  | Up | Left | Right | Op | Val

(* In this grammar, we allow abnormal arithmetic expressions, and operators are denoted
    by ints 10-12. Values can be 1-9 or 21-29 *)
let mygrammar = 
  (Up,
   function
    | Up ->
        [[N Left; N Op; N Right];
         [N Op];
         [N Left; N Op]]
    | Left ->
        [[N Op; N Val];
         [N Val]]
    | Right ->
        [[N Up; N Val];
         [T 21];
         [N Op; T 22]]
    | Op ->
       [[T 10];
        [T 11];
        [T 12];]
    | Val ->
        [[T 1]; [T 2]; [T 3]; [T 4]; [T 5]; [T 6];
         [T 7; T 8; T 9]]
      )

(* acceptor that accepts only the empty list *)
let accept_empty = function
  | [] -> Some []
  | _ -> None

(* acceptor that only accepts a frag that begins with 1 *)
let accept_one frag =
  match List.hd frag with
  | 1 -> Some frag
  | _ -> None

(* accept the first matching prefix *)
let make_matcher_test =
  ((make_matcher mygrammar accept_one [1; 11; 21; 1]) = Some [1])

(* skip a prefix because the acceptor didn't like it. then accept a later prefix *)
let make_matcher_test_2 =
  ((make_matcher mygrammar accept_one [12; 2; 10; 1; 4]) = Some [1;4])

(* skip every matching prefix until you match the entire frag *)
let make_matcher_test_3 =
  ((make_matcher mygrammar accept_empty [2; 10; 11; 22]) = Some [])

(* test a case where there exist no acceptable prefixes *)
let make_matcher_test_4 =
  ((make_matcher mygrammar accept_empty [9;12;24]) = None)

(* test a case with the empty list, which should not match anything (i.e. return None) *)
let make_matcher_test_4 =
  ((make_matcher mygrammar accept_empty []) = None)

let test_frag = [2;11;10;22]
let correct_tree =
  Some
   (Node (Up,
     [Node (Left, [Node (Val, [Leaf 2])]);
      Node (Op, [Leaf 11]);
      Node (Right, [Node (Op, [Leaf 10]);
                    Leaf 22])]))

let make_parser_test =
  let parser_tree = make_parser mygrammar test_frag in
  match parser_tree with
  | None -> false
  | Some tree ->
  (parser_tree = correct_tree) && (parse_tree_leaves tree = test_frag)