type ('nonterminal, 'terminal) symbol =
| N of 'nonterminal
| T of 'terminal;;

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal


let convert_grammar gram1 =
  (* extract start symbol and rule list from hw1 grammar*)
  let start, rules = gram1 in
  (* "filter_rules" keeps only the rules whose LHS is "symb" *)
  let filter_rules = fun rule_list symb ->
    List.filter (fun el -> fst el = symb) rule_list in
  (* "producer_fun" returns the alternative list for "sym" *)
  let producer_fun sym = List.map (fun x -> snd x) (filter_rules rules sym) in
  (* return the hw2 grammar *)
  (start, producer_fun)


let rec parse_tree_leaves tree =
  match tree with
  | Leaf x -> [x]
  | Node (sym, tree_list) -> List.concat_map (fun el -> parse_tree_leaves el) tree_list




(* calls matcher1 on the frag and the acceptor of that is a call of matcher2 on the frag *)
let concat_matcher matcher1 matcher2 accept frag =
  matcher1 (fun suffix -> matcher2 accept suffix) frag

(* checks if the first terminal in frag matches "term". If so,
  it calls the acceptor on the tail. else it returns None because there
  is no match *)
let terminal_matcher terminal_symb accept frag =
  match frag with
  | [] -> (None, [])
  | t::tail -> match t = terminal_symb with
      | true -> accept tail
      | false -> (None, [])

(* returns a matcher for a nonterminal symbol with the given fragment *)
let nonterminal_matcher nonterminal_symb producer_fun matcher_fun accept frag = 
  matcher_fun (nonterminal_symb, producer_fun) accept frag
  
(* turn one rule (i.e. "rhs") into a single matcher. returns a single matcher
   that checks if a a frag matches a rhs *)
let rhs_matcher_plus_der rhs producer_fun make_a_matcher accept frag =
  let rec process_rhs = function
    | [] -> (fun acceptor fragment -> acceptor fragment)
    | h::t ->
        match h with
          | T x -> concat_matcher (terminal_matcher x) (process_rhs t)
          | N y -> concat_matcher (nonterminal_matcher y producer_fun make_a_matcher) (process_rhs t)
  in
  process_rhs rhs accept frag

  
(* returns expected matcher result + derivation in a single tuple *)
let rec matcher_plus_der gram accept frag =
  (* extract start symbol, producer function, and alternative list associated with the start symbol *)
  let start_sym, producer_fun = gram in
  let alt_list = producer_fun start_sym in
  (* define a function to check every rule in the alternative list and see if one works *)
  let rec process_alt_list ls =
    match ls with
      | [] -> (None, [])
      | h::t ->
          (* try to match with h *)
          let match_result, der = rhs_matcher_plus_der h producer_fun matcher_plus_der accept frag in
          match match_result with
          | None -> process_alt_list t
          | Some _ -> (match_result, h::der)
  in
  (* check if any of the rules in the alternative list for the start symbol match with the frag *)
  process_alt_list alt_list

let matcher_plus_der_wrapper gram accept frag =
  let new_accept = fun some_frag -> (accept some_frag, []) in
  matcher_plus_der gram new_accept frag

let make_matcher gram accept frag = 
  let match_result, der = matcher_plus_der_wrapper gram accept frag in
  match_result


(* returns tuple of... (list of trees, list of remaining rules) *)
let rec make_tree_list sym_list rules_list tree_maker = 
  match sym_list with
  | [] -> ([], rules_list)
  | sym::rest_symbols ->
      let head_tree, new_rules_list = tree_maker sym rules_list in
      let other_trees, remaining_rules = make_tree_list rest_symbols new_rules_list tree_maker in
      (head_tree::other_trees, remaining_rules)

(* takes start symbol and rule list. return tuple of ... (tree, list of remaining rules) *)
let rec make_tree start_sym rules_list =
  match start_sym with
  | T x -> (Leaf x, rules_list)
  | N y -> 
      match rules_list with
      | [] -> (Node (y, []), [])
      | head_rule::tail -> (* make list of trees for head rule *)
          let head_rule_tree_list, remaining_rules = make_tree_list head_rule tail make_tree in
          (Node (y, head_rule_tree_list), remaining_rules)


let make_parser gram frag =
  (* extract start symbol, producer function, and alternative list associated with the start symbol *)
  let start_sym, producer_fun = gram in
  let accept_only_empty = function | [] -> Some [] | _ -> None in
  let matcher_result, derivation = matcher_plus_der_wrapper gram accept_only_empty frag in
  (* fst (make_tree (fst gram) derivation) *)
  (*let tree, remaining_rules = make_tree start_sym derivation in
  tree*)
  (* derivation *)
  match matcher_result with
  | None -> None
  | _ -> 
    let list_of_trees, remaining_rules = make_tree_list (List.hd derivation) (List.tl derivation) make_tree in
    Some (Node (start_sym, list_of_trees))



(* NO LONGER NEEDED ... *)

(* let make_parser_1 gram frag = 
  (* extract start symbol, producer function, and alternative list associated with the start symbol *)
  let start_sym, producer_fun = gram in
  let accept_only_empty = function | [] -> Some [] | _ -> None in
  let match_result, der = matcher_plus_der_wrapper gram accept_only_empty frag in
  der *)


(* let foo rules_list start_sym =
  match rules_list with
  | [] -> (0, start_sym)
  | h::t ->
      match h with
      | [] -> (0, start_sym)
      | head::tail ->
          match head with
          | T x -> (1, start_sym)
          | N y -> (2, start_sym)

let make_tree_call derivation gram =
  make_tree (fst gram) derivation *)


  (* (* takes a rule (i.e. symbol list) and a list of rules.
   returns a tuple of a list of trees and the remaining rules  *)
let rec rule_to_trees symb_list rules_list tree_maker=
  match symb_list with
  | [] -> ([], rules_list)
  | h::t ->
      let head_tree, remaining_rules1 = tree_maker h rules_list in
      let other_trees_list, remaining_rules2 = rule_to_trees t remaining_rules1 tree_maker in
      match head_tree with
      | None -> ([], remaining_rules2)
      | Some x -> (x::other_trees_list, remaining_rules2)
      

(* given a start_symbol and rules_list, returns tuple of a valid tree and remaining rules *)
let rec make_tree start_symbol rules_list =
  match start_symbol with
  | T x -> (Some (Leaf x), rules_list)
  | N y ->
      match rules_list with
      | [] -> (Some (Node (y, [])), [])
      | h::t ->
          let child_list, remaining_rules = rule_to_trees h t make_tree in
          (Some (Node (y, child_list)), remaining_rules) *)