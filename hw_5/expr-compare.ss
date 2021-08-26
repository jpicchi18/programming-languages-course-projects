#lang racket
(provide expr-compare)


(define (expr-compare x y)
  (expr-compare-helper x y '()))


; The first ~15 lines of this function are based on the hint code on the CS 131 TA github
(define (expr-compare-helper x y binding-list)
  ; if x and  y are the same, return x
  (cond [(and (equal? x y) (or (not (list? x)) (null? x)))
	 (output-symbol x y binding-list)]

	; if x and y are both booleans, then return % or '(not %)
	[(and (boolean? x) (boolean? y)) 
         (if x '% '(not %))]
	
        ; if one is not a list, then return "(if % x y)"
        [(or (not (list? x)) 
             (not (list? y)))
	 (if-statement-with-bindings x y binding-list)]

	; if x and y have different lengths, return "(if % x y)"
	[(not (= (length x) (length y)))
	 (if-statement-with-bindings x y binding-list)]

	; if cars are both 'quote, then handle it
	[(and (equal? (car x) 'quote) (equal? (car y) 'quote))
	 (handle-quotes x y)]

	; if both cars are lambda expressions of some form, then handle it
	[(both-lambdas? x y binding-list)
	 (cons (handle-lambdas (car x) (car y) binding-list)
	       (expr-compare-helper (cdr x) (cdr y) binding-list))]
	
	; if cars are eqiuvalent and it's not a keyword, then it's a function call
	[(equal? (car x) (car y))
	 (cons (output-symbol (car x) (car y) binding-list)
	       (expr-compare-helper (cdr x) (cdr y) binding-list))]

	; if cars are not equivalent...
	[(not (equal? (car x) (car y)))
	 ; if they're both lists, recurse on them
	 (cond [(and (list? (car x)) (list? (car y)))
		(cons (expr-compare-helper (car x) (car y) binding-list)
		      (expr-compare-helper (cdr x) (cdr y) binding-list))]
	       ; if one of them is an if statement, then handle this
	       [(if-statement-without-binding? x y binding-list)
		(if-statement-with-bindings x y binding-list)]
	       ; else they're not lists or booleans, so get the correct symbol
	       [#t (cons (output-symbol (car x) (car y) binding-list)
			 (expr-compare-helper (cdr x) (cdr y) binding-list))])]
	
	
	; if x and y are lists that dont match our special forms, then they're
	; function calls --> 
	[#t '()]))


(define (if-statement-with-bindings x y binding-list)
  (let ([x-binding (cond [(list? x) (find-bindings x 1 binding-list)]
			 [#t (bind-el1 x binding-list)])]
	[y-binding (cond [(list? y) (find-bindings y 2 binding-list)]
			 [#t (bind-el2 y binding-list)])])
    (list 'if '% x-binding y-binding)))


; replaces all elements of "list" with their bindings in "binding-list", using
; "pos" as an index into each binding that for the position that should match
; each element of list (i.e. pos=1 when we pass in x as "list" and pos=2 when we
; pass in y as "list"
(define (find-bindings list pos binding-list)
  (cond [(empty? list) '()]
	[#t
	 (let ([el-binding (cond [(and (list? (car list)) (not (equal? (caar list) 'quote)))
				  (find-bindings (car list) pos binding-list)]
				 [(equal? pos 1) (bind-el1 (car list) binding-list)]
				 [#t (bind-el2 (car list) binding-list)])])
	   (cons el-binding (find-bindings (cdr list) pos binding-list)))]))

  


; returns #t if one of x or y is an if statement and 'if is not in the binding list
; for that list. else returns #f
(define (if-statement-without-binding? x y binding-list)
  (or (and (equal? (car x) 'if) (not (member-of-list? 'if (map car binding-list))))
      (and (equal? (car y) 'if) (not (member-of-list? 'if (map cadr binding-list))))))
  


; returns #t if (car x) and (car y) are both lambda expressions and
; 'lambda does not appear in the bindings list while x or y is 'lambda
(define (both-lambdas? x y binding-list)
  (and (list? (car x)) (list? (car y)) (lambda? (caar x)) (lambda? (caar y))))
       ;(not (and (equal? (caar x) 'lambda) (member-of-list? 'lambda (map car binding-list))))
       ;(not (and (equal? (caar y) 'lambda) (member-of-list? 'lambda (map cadr binding-list))))))


; returns #t if el is a member of list, and returns #f otherwise
(define (member-of-list? el list)
  (cond [(null? list) #f]
	[(equal? el (car list)) #t]
	[#t (member-of-list? el (cdr list))]))


(define (output-symbol el1 el2 binding-list)
  (cond [(and (boolean? el1) (boolean? el2) (not (equal? el1 el2)))
	 (if el1 '% '(not %))]
	[#t (let ([el1-bound (bind-el1 el1 binding-list)]
		  [el2-bound (bind-el2 el2 binding-list)])
	      (cond [(equal? el1-bound el2-bound)
		     el1-bound]
		    [#t (list 'if '% el1-bound el2-bound)]))]))
	

(define (bind-el1 el1 binding-list)
  (cond [(empty? binding-list) el1]
	[(equal? el1 (caar binding-list))
	 (combine-symbols el1 (cadar binding-list))]
	[#t (bind-el1 el1 (cdr binding-list))]))


(define (bind-el2 el2 binding-list)
  (cond [(empty? binding-list) el2]
	[(equal? el2 (cadar binding-list))
	 (combine-symbols (caar binding-list) el2)]
	[#t (bind-el2 el2 (cdr binding-list))]))


; takes 2 symbols 'a and 'b, and it outputs 'a!b
(define (combine-symbols a b)
  (string->symbol (string-append (symbol->string a) "!" (symbol->string b))))


; call this when (car x) and (car y) are both 'quote
(define (handle-quotes x y)
  (cond [(equal? x y) x]
	[#t (list 'if '% x y)]))
    

; returns true if el is one of the 2 lambda forms
(define (lambda? el)
  (cond [(or (equal? el 'lambda) (equal? el 'λ)) #t]
	[#t #f]))


(define (handle-lambdas x y binding-list)
  (let ([new-binding-list (append (get-bindings (cadr x) (cadr y))
				  (filter-bindings binding-list (cadr x) (cadr y)))]
	[lambda-symbol (get-lambda-symbol (car x) (car y))])
    (cons lambda-symbol (expr-compare-helper (cdr x) (cdr y) new-binding-list))))


; filter out the existing bindings that apply to elements in x-formals or y-formals
(define (filter-bindings binding-list x-formals y-formals)
  (cond [(null? binding-list) binding-list]
	[(or (member-of-list? (caar binding-list) x-formals)
	     (member-of-list? (cadar binding-list) y-formals))
	 (filter-bindings (cdr binding-list) x-formals y-formals)]
	[#t (cons (car binding-list) (filter-bindings (cdr binding-list) x-formals y-formals))]))


; if el1 and el2 are different lambda symbols, it outputs 'λ
; else it outputs the lambda symbol bound to both
(define (get-lambda-symbol el1 el2)
  (cond [(and (not (equal? el1 el2)) (lambda? el1) (lambda? el2)) 'λ]
	[#t el1]))


; takes 2 formals lists from lambda expressions and returns a list of lists
; of lists representing bound variable pairs
(define (get-bindings x-formals y-formals)
  (cond [(empty? x-formals) '()]
	[(equal? (car x-formals) (car y-formals))
	 (get-bindings (cdr x-formals) (cdr y-formals))]
	[#t (cons (list (car x-formals) (car y-formals))
		  (get-bindings (cdr x-formals) (cdr y-formals)))]))


; SOURCE CREDIT: this function was copied from the CS 131 TA github
(define (test-expr-compare x y) 
  (and (equal? (eval x)
               (eval `(let ((% #t)) ,(expr-compare x y))))
       (equal? (eval y)
               (eval `(let ((% #f)) ,(expr-compare x y))))))


(define test-expr-x '(if #t (cons ((lambda (a b) ((lambda (a c) (list a b c)) a b)) 1 4)
				  '(4 5))
			 ((λ (e f) (or e f)) 6 #t)) )

(define test-expr-y '(if #f (append ((λ (b a) ((lambda (x y) (cons '(a w) (list b x y))) 4 1))
				     1 4) '(5 4))
			 ((λ (g h) (if #t g h)) (+ 3 1) #f)) )



; TEST CASES

#|

(equal? (expr-compare 12 12) '12)
(equal? (expr-compare 12 20) '(if % 12 20))
(equal? (expr-compare #t #t) '#t)
(equal? (expr-compare #f #f) '#f)
(equal? (expr-compare #t #f) '%)
(equal? (expr-compare #f #t) '(not %))
(display "\n")

(equal? (expr-compare '(/ 1 0) '(/ 1 0.0)) '(/ 1 (if % 0 0.0)))
(display "\n")

(equal? (expr-compare 'a '(cons a b)) '(if % a (cons a b)))
(equal? (expr-compare '(cons a b) '(cons a b)) '(cons a b))
(equal? (expr-compare '(cons a lambda) '(cons a λ))  '(cons a (if % lambda λ)))

(equal? (expr-compare '(cons (cons a b) (cons b c))
		      '(cons (cons a c) (cons a c)))
	'(cons (cons a (if % b c)) (cons (if % b a) c)))
(equal? (expr-compare '(cons a b) '(list a b)) '((if % cons list) a b))
(equal? (expr-compare '(list) '(list a)) '(if % (list) (list a)))
(equal? (expr-compare ''(a b) ''(a c)) '(if % '(a b) '(a c)))
(equal? (expr-compare '(quote (a b)) '(quote (a c))) '(if % '(a b) '(a c)))
(equal? (expr-compare '(quoth (a b)) '(quoth (a c))) '(quoth (a (if % b c))))
(equal? (expr-compare '(if x y z) '(if x z z)) '(if x (if % y z) z))
(equal? (expr-compare '(if x y z) '(g x y z)) '(if % (if x y z) (g x y z)))
(display "\n")

; lambda tests
(equal? (expr-compare '((lambda (a) (f a)) 1) '((lambda (a) (g a)) 2))
	'((lambda (a) ((if % f g) a)) (if % 1 2)))
(equal? (expr-compare '((lambda (a) (f a)) 1) '((λ (a) (g a)) 2))
	'((λ (a) ((if % f g) a)) (if % 1 2)))
(equal? (expr-compare '((lambda (a) a) c) '((lambda (b) b) d))
	'((lambda (a!b) a!b) (if % c d)))
(equal? (expr-compare ''((λ (a) a) c) ''((lambda (b) b) d))
	'(if % '((λ (a) a) c) '((lambda (b) b) d)))
(equal? (expr-compare '(+ #f ((λ (a b) (f a b)) 1 2))
		      '(+ #t ((lambda (a c) (f a c)) 1 2)))
	'(+ (not %) ((λ (a b!c) (f a b!c)) 1 2)))
(equal? (expr-compare '((λ (a b) (f a b)) 1 2)
		      '((λ (a b) (f b a)) 1 2))
	'((λ (a b) (f (if % a b) (if % b a))) 1 2))
(equal? (expr-compare '((λ (a b) (f a b)) 1 2)
		      '((λ (a c) (f c a)) 1 2))
	'((λ (a b!c) (f (if % a b!c) (if % b!c a)))
	  1 2))



(equal? (expr-compare '((lambda (lambda) (+ lambda if (f lambda))) 3)
		      '((lambda (if) (+ if if (f λ))) 3))
	'((lambda (lambda!if) (+ lambda!if (if % if lambda!if) (f (if % lambda!if λ)))) 3))


(equal? (expr-compare
	 '((lambda (a) (eq? a
			    ((λ (a b) ((λ (a b) (a b))
				       b
				       a))
			     a
			     (lambda (a) a))))
	   (lambda (b a) (b a)))

	 '((λ (a) (eqv? a
			((lambda (b a) ((lambda (a b) (a b))
					b
					a))
			 a
			 (λ (b) a))))
	   (lambda (a b) (a b))))

	'((λ (a) ((if % eq? eqv?) a
		  ((λ (a!b b!a) ((λ (a b) (a b))
				 (if % b!a a!b)
				 (if % a!b b!a)))
		   a
		   (λ (a!b) (if % a!b a)))))
	  (lambda (b!a a!b) (b!a a!b))))


|#
