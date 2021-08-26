# ASSIGNMENT: Naive Parsing of Context-Free Grammars
- full spec is [hw2_spec.ml](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_2/hw2_spec.pdf).
- Code is in [hw2.ml](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_2/hw2.ml).
- Textual description of implementation in [hw2.txt](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_2/hw2.txt).

## summary
- Implemented a grammar converter function that converts an OCaml-represented grammar from one form to another.
- **parse_tree_leaves tree**: traverses a parse tree left to right and creates a list of the leaves.
- **make_matcher gram**: returns a matcher for the grammar *gram*. 
  - When applied to an acceptor accept and a fragment frag, the matcher must try the grammar rules in order and return the result of
    calling accept on the suffix corresponding to the first acceptable matching prefix of frag; this is not necessarily the shortest or the
    longest acceptable match.
  - A match is considered to be acceptable if accept succeeds when given the suffix fragment that immediately follows the matching prefix.
  - When this happens, the matcher returns whatever the acceptor returned.
  - If no acceptable match is found, the matcher returns None.
- **make_parser gram**: returns a parser for the grammar *gram*.
  - When applied to a fragment frag, the parser returns an optional parse tree.
  - If frag cannot be parsed entirely (that is, from beginning to end), the parser returns None.
  - Otherwise, it returns Some tree where tree is the parse tree corresponding to the input fragment.
