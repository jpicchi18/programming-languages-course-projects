# ASSIGNMENT: KenKen puzzle solver
 - full project spec: [hw5_spec.pdf](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_5/hw5_spec.pdf)
 - code file: [expr-compare.ss](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_5/expr-compare.ss)

## Language
Scheme (Lisp)

## Description
- created a procedure *expr-compare* that compares two Scheme expressions *x* and *y* and produces a difference summary.
- The difference summary is another scheme expression
  - if executed in an environment where the value of a particular variable is *true*, the difference summary has the same behavior as *x*
  - if executed in an environment where the value of a particular variable is *false*, the difference summary has the same behavior as *y*
