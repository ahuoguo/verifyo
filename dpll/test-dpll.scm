(load "../mk/mk.scm")
(load "../mk/test-check.scm")
(load "dpll.scm")

(test "a is a literal"
      (run 1 (q) (lito 'a))
      '((_.0)))

(test "1 is not a literal"
      (run 1 (q) (lito 1))
      '())

(test "() is not a literal"
      (run 1 (q) (lito '()))
      '())

(test "(a) is not a literal"
      (run 1 (q) (lito '(a)))
      '())

(test "(¬ a) is a literal"
      (run 1 (q) (lito '(¬ a)))
      '((_.0)))

(test "(¬ 1) is not a literal"
      (run 1 (q) (lito '(¬ 1)))
      '())

(test "(¬ (a)) is not a literal"
      (run 1 (q) (lito '(¬ (a))))
      '())

(test "(a b c) is a clause"
      (run 1 (q) (clauseo '(a b c)))
      '((_.0)))

(test "(a b c (¬ d)) is a clause"
      (run 1 (q) (clauseo '(a b c (¬ d))))
      '((_.0)))

(test "(a b (c)) is not a clause"
      (run 1 (q) (clauseo '(a b (c))))
      '())

(test "((a b c) (d e f)) is a CNF formula"
      (run 1 (q) (formulao '((a b c) (d e f))))
      '((_.0)))

(test "((a b c) (d e f) ((¬ a))) is a CNF formula"
      (run 1 (q) (formulao '((a b c) (d e f) ((¬ a)))))
      '((_.0)))

(test "((a b c) (d e f) ((¬ a)) a) is not a CNF formula"
      (run 1 (q) (formulao '((a b c) (d e f) ((¬ a)) a)))
      '())

;======================================================

(test "'(a b c) ∩ '(a b c) ≡ '(a b c)"
      (run 1 (q) (intersecto '(a b c) '(a b c) '(a b c)))
      '((_.0)))

(test "'(a) ∩ '(a b c) ≡ '(a)"
      (run 1 (q) (intersecto '(a) '(a b c) '(a)))
      '((_.0)))

(test "'(a) ∩ '() ≡ '()"
      (run 1 (q) (intersecto '(a) '() '()))
      '((_.0)))

(test "'() ∩ '(a) ≡ '()"
      (run 1 (q) (intersecto '() '(a) '()))
      '((_.0)))

(test "'(a b) ∩ '(a b c) ≡ '(a b)"
      (run 1 (q) (intersecto '(a b) '(a b c) '(a b)))
      '((_.0)))

(test "'(a b) ∩ '(a b c) ≡ {q}"
      (run* (q) (intersecto '(a b) '(a b c) q))
      '(((a b))))

;======================================================

(test "(nego p (¬ p))"
      (run 1 (q) (nego 'p '(¬ p)))
      '((_.0)))

(test "reverse nego identity"
      (run 1 (q1 q2)
           (nego 'p q1)
           (nego q1 q2)
           (== q2 'p))
      '((((¬ p) p))))

;======================================================

(test "(splito '(a b c) '() 'a '(b c)"
      (run 1 (q) (splito '(a b c) '() 'a '(b c)))
      '((_.0)))

(test "(splito '(a b c) '(a) 'b '(c)"
      (run 1 (q) (splito '(a b c) '(a) 'b '(c)))
      '((_.0)))

(test "(splito '(a b c d e) '(a b c d) 'e '()"
      (run 1 (q) (splito '(a b c d e) '(a b c d) 'e '()))
      '((_.0)))

(test "(splito '(a b c d e) '(a b c d) 'e '()"
      (run 1 (q) (splito '(a b c d e) '(a b c d) 'g q))
      '())

;======================================================

(test "(rem-dupo '(a b c a) '(b c a))"
      (run 1 (q) (rem-dupo '(a b c a) '(b c a)))
      '((_.0)))

(test "(rem-dupo '(a b c b a) '(c b a))"
      (run 1 (q) (rem-dupo '(a b c b a) '(c b a)))
      '((_.0)))

(test "(rem-dupo '() '())"
      (run 1 (q) (rem-dupo '() '()))
      '((_.0)))

(test "(rem-dupo '(a a a) '(a))"
      (run 1 (q) (rem-dupo '(a a a) '(a)))
      '((_.0)))

(test "(flatteno '((a b c) (d e f)) '(a b c d e f))"
      (run 1 (q) (flatteno '((a b c) (d e f)) '(a b c d e f)))
      '((_.0)))

(test "(flatteno '((a b c) ()) '(a b c))"
      (run 1 (q) (flatteno '((a b c) ()) '(a b c)))
      '((_.0)))

(test "(flatteno '(((¬ a) b c) ((¬ d))) '((¬ a) b c (¬ d)))"
      (run 1 (q) (flatteno '(((¬ a) b c) ((¬ d))) '((¬ a) b c (¬ d))))
      '((_.0)))

(test "(⊆ '(a b c) '(c b a))"
      (run 1 (q) (⊆ '(a b c) '(c b a)))
      '((_.0)))

(test "(⊆ '(a b c) '(c b))"
      (run 1 (q) (⊆ '(a b c) '(c b)))
      '())

;======================================================

(test "(a b) ⊨ (a b)"
      (run 1 (q) (c/⊨ '(a b) '(a b)))
      '((_.0)))

(test "(a) ⊨ (a b)"
      (run 1 (q) (c/⊨ '(a) '(a b)))
      '((_.0)))

(test "(a (¬ b)) ⊨ (a b)"
      (run 1 (q) (c/⊨ '(a (¬ b)) '(a b)))
      '((_.0)))

(test "((¬ b)) ⊨ (a (¬ b))"
      (run 1 (q) (c/⊨ '((¬ b)) '(a (¬ b))))
      '((_.0)))

(test "(b) ⊨ (a (¬ b)) ;; undefined, since a is unspecified"
      (run 1 (q) (c/⊨ '(b) '(a (¬ b))))
      '())

(test "((¬ a)) ⊨ (a (¬ b)) ;; undefined, since b is unspecified"
      (run 1 (q) (c/⊨ '((¬ a)) '(a (¬ b))))
      '())

;======================================================

(test "((¬ a) b) ⊭ (a (¬ b))"
      (run 1 (q) (c/⊭ '((¬ a) b) '(a (¬ b))))
      '((_.0)))

(test "(b) ⊭ (a (¬ b)) ;; undefined"
      (run 1 (q) (c/⊭ '(b) '(a (¬ b))))
      '())

(test "{q} ⊭ (a (¬ b))"
      (run 1 (q) (c/⊭ q '(a (¬ b))))
      '((((¬ a) b . _.0))))

;======================================================

(test "(a b) ⊨ ((a) (b))"
      (run 1 (q) (f/⊨ '(a b) '((a) (b))))
      '((_.0)))

(test "(a) ⊨ ((a) (b)) ;; undefined"
      (run 1 (q) (f/⊨ '(a) '((a) (b))))
      '())

(test "{q} ⊨ ((a) (b c e) ((¬ b)) ((¬ c)))"
      (run 1 (q)
           (consistento q)
           (f/⊨ q '((a) (b c e) ((¬ b)) ((¬ c)))))
      '(((a (¬ b) (¬ c) e))))

;======================================================

(test "((¬ a)) ⊭ ((a) (b))"
      (run 1 (q) (f/⊭ '((¬ a)) '((a) (b))))
      '((_.0)))

;======================================================

(test "(finalo '(a b c) '((a) (b) (c a) (b c)))"
      (run 1 (q) (finalo '(a b c) '((a) (b) (c a) (b c))))
      '((_.0)))

(test "(finalo '((¬ a) (¬ b) c) '((a) (b) (c a) (b c)))"
      (run 1 (q) (finalo '((¬ a) (¬ b) c) '((a) (b) (c a) (b c))))
      '((_.0)))

(test "solve '((a b))"
      (run 1 (d m) (dpllo '() '() '((a b)) d m))
      '(((_.0 (a b)))))

(test "solve '((a b) ((¬ b)))"
      (run 1 (d m) (dpllo '() '() '((a b) ((¬ b))) d m))
      '(((_.0 (a (¬ b))))))

#|
(test "disprove '((a b) ((¬ a)) ((¬ b)))"
      (run 1 (d m) (dpllo '() '() '((a b) ((¬ a)) ((¬ b))) d m))
      '())
|#

(define f1
  '((a b c) (d e f) (g h i)
    ((¬ a) (¬ c))
    (b)
    ((¬ d))
    ((¬ f))
    (e)
    (g)
    (h)
    ((¬ i))))

;(time (run 1 (d m) (dpllo '() '() f1 d m)))
;(time (run 1 (m) (f/⊨ m f1)))


