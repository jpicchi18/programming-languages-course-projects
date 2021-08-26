type ('terminal, 'nonterminal) symbol =
| N of 'nonterminal
| T of 'terminal

(* QUESTION 1... *)
(* checks if a is a subset of b *)
let rec subset a b = match a with
| [] -> true
| head :: rest -> List.mem head b && subset rest b

(* QUESTION 2... *)
(* checks if a and b are equal sets *)
let equal_sets a b =
  subset a b && subset b a

(* QUESTION 3... *)
(* returns the union of a and b *)
let set_union a b =
  a @ b

(* QUESTION 4... *)
(* returns the union of all elements of a *)
let rec set_all_union a = match a with
| [] -> []
| head :: rest -> head @ set_all_union rest

(*
QUESTION 5...
We can NOT write such a function due to the type checking rules of Ocaml.
This is proven by the following proof by contradiction...
1. We are representing sets as lists.
2. The type of list s is 'a list, where 'a is the type of each element
  in s.
3. Suppose that s contains itself.
4. By (2) and (3), s is of type 'a because it is an element of s.
5. (2) and (4) contradict
6. Therefore, by the type checking rules of Ocaml, we can NOT possibly compile a
  function that successfully checks if s is a member of itself.

We can verify the proof above by attempting to write such a function "self_member s"...

    let self_member s =
      List.mem s s;;

As expected, Ocaml gives the following error due to the type mismatch described in the
proof above...

    This expression has type 'a but an expression was expected of type
      'a list
    The type variable 'a occurs inside 'a list
*)

(* QUESTION 6... *)
(* finds a fixes point *)
let rec computed_fixed_point eq f x =
  if eq (f x) x then x
  else computed_fixed_point eq f (f x)

(* QUESTION 7... *)

(* helper: check if first elements of a tuple are equivalent sets *)
let first_el_eq a b =
  let f_1, f_2 = a in
  let s_1, s_2 = b in
  equal_sets f_1 s_1

(* helper: get nonterminals from a tuple a *)
let get_nonterminals a =
  let is_nonterminal x = match x with
  | N _ -> true
  | T _ -> false in
  List.filter is_nonterminal a

(* helper: add any symbols we don't already have. a is a tuple=([symbols], rules) *)
let rec add_symbols a =
  let symbol_list, rule_list = a in
  match rule_list with
  | [] -> (symbol_list, rule_list)
  | current_rule :: rest_of_rules ->
    let lhs, rhs = current_rule in
    if List.mem (N lhs) symbol_list then
      (* add nonterminals from RHS *)
      let non_terminals = get_nonterminals rhs in
      add_symbols (set_union symbol_list non_terminals, rest_of_rules)
    else
      (* do NOT add nonterminals from RHS *)
      add_symbols (symbol_list, rest_of_rules)

(* wrapper: calls add_symbols to get the reachable symbols, then adds back
            the complete rule set to the resulting tuple *)
let add_symbols_wrapper tup =
  let symbol_list, rule_list = tup in
  let reachable_symbols, new_rule_list = add_symbols tup in
  (reachable_symbols, rule_list)

(* helper: filters out rules, keeping only those whose LHS appears in the symbols list *)
let get_reachable_rules symbols rule_list =
  (* define predicate to check if nonterminal is in list *)
  let lhs_is_valid rule =
    let lhs, rhs = rule in
    List.mem (N lhs) symbols in
  (* filter rules *)
  List.filter lhs_is_valid rule_list

let filter_reachable g =
  let start_sym, rules = g in
  (* get list of reachable symbols *)
  let reachable_symbols, y = computed_fixed_point first_el_eq add_symbols_wrapper ([N start_sym], rules) in
  (* filter out rules that cannot be reached *)
  let reachable_rules = get_reachable_rules reachable_symbols rules in
  (start_sym, reachable_rules)