# ASSIGNMENT: Representing and Operating on Sets with OCaml
- Full spec located at [hw1_spec.pdf](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_1/hw1_spec.pdf).
- Answers are in the files [hw1.ml](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_1/hw1.ml) and 
[hw1.txt](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_1/hw1.txt).

## Lanuage Used
OCaml

## Functions Implemented

### subset a b
returns true iff (i.e., if and only if) a⊆b, i.e., iff the set represented by the list a is a
    subset of the set represented by the list b. This function is curried, and is generic to lists of any type: that is, the type of
    subset is a generalization of **'a list -> 'a list -> bool**.

### equal_sets a b
returns true iff the represented sets are equal.

### set_union a b
returns a list representing "a union b".

### set_all_union a
returns a list representing the union of all the members of the set a; a should represent a set of sets.

### Russell's Paradox
Write a function *self_member s* that returns true iff the set
represented by s is a member of itself, and explain in a comment why your function is correct; or, if it's not possible to write such a function
in OCaml, explain why not in a comment.

### computed_fixed_point eq f x
returns the computed fixed point for f with respect to x, assuming that eq is the
equality predicate for f's domain.

### filter_reachable g
returns a copy of the grammar g with all unreachable rules removed.
