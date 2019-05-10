;;(load "mk/test-check.scm")
;;(load "evalo-optimized.scm")
(load "mk/mk.scm")
(load "arithmetic.scm")
(load "membero.scm")
(set! allow-incomplete-search? #t)

(define uop '(not))
(define bop '(= >= > < <= + - * and or))

;; TODO: does it terminate?
(define (normo p q)
  (conde
   [(fresh (r)
           (rewriteo p r)
           (normo r q))]
   [(== p q)]))

;; TODO
(define (rewriteo p q)
  (conde
   ;; Reflexivity
   [(fresh (x)
           (== p `(= ,x ,x))
           (== q 'true))]
   [(fresh (x)
           (== p `(>= ,x ,x))
           (== q 'true))]
   [(fresh (x)
           (== p `(<= ,x ,x))
           (== q 'true))]
   ;; Congruence of unary operators
   [(fresh (op p^ q^)
           (== p `(,op ,p^))
           (== q `(,op ,q^))
           (membero op uop)
           (rewriteo p^ q^))]
   ;; Congruence of binary operators
   [(fresh (op p1 p2 q1 q2)
           (== p `(,op ,p1 ,p2))
           (== q `(,op ,q1 ,q2))
           (membero op bop)
           (rewriteo p1 q1)
           (rewriteo p2 q2))]
   ;; Prefer right-associativity over left-associativity
   [(fresh (p1 p2 p3)
           (== p `(and (and ,p1 ,p2) ,p3))
           (== q `(and ,p1 (and ,p2 ,p3))))]
   [(fresh (p1 p2 p3)
           (== p `(or (or ,p1 ,p2) ,p3))
           (== q `(or ,p1 (or ,p2 ,p3))))]
   ;; Unit laws
   [(fresh (p^)
           (conde
            [(== p `(and true ,p^))
             (== q p^)]
            [(== p `(and ,p^ true))
             (== q p^)]))]
   [(fresh (p^)
           (conde
            [(== p `(or false ,p^))
             (== q p^)]
            [(== p `(or ,p^ false))
             (== q p^)]))]
   [(fresh (x)
           (conde
            [(== p `(+ (int ()) ,x))
             (== q x)]
            [(== p `(+ ,x (int ())))
             (== q x)]))]
   [(fresh (x)
           (== p `(- ,x (int ())))
           (== q x))]
   [(fresh (x)
           (conde
            [(== p `(* (int (1)) ,x))
             (== q x)]
            [(== p `(* ,x (int (1))))
             (== q x)]))]
   ;; Zero laws
   [(fresh (p^)
           (conde
            [(== p `(and false ,p^))
             (== q 'false)]
            [(== p `(and ,p^ false))
             (== q 'false)]))]
   [(fresh (p^)
           (conde
            [(== p `(or true ,p^))
             (== q 'true)]
            [(== p `(or ,p^ true))
             (== q 'true)]))]
   [(fresh (p^)
           (conde
            [(== p `(* (int ()) ,p^))
             (== q (int 0))]
            [(== p `(* ,p^ (int ())))
             (== q (int 0))]))]))

(define (substo* p x t q)
  (conde
   [(== p q) (numbero p)]
   [(symbolo p)
    (== p x)
    (== t q)]
   [(symbolo p)
    (=/= p x)
    (== p q)]
   [(fresh (op p^ q^)
           (== p `(,op ,p^))
           (== q `(,op ,q^))
           (membero op uop)
           (substo* p^ x t q^))]
   [(fresh (op p1 p2 q1 q2)
           (== p `(,op ,p1 ,p2))
           (== q `(,op ,q1 ,q2))
           (membero op bop)
           (substo* p1 x t q1)
           (substo* p2 x t q2))]))

(define (implieso* p q)
  (conde
   [(== p q)]
   [(== q 'true)]
   [(== p 'false)]
   [(fresh (r s w v)
           (== p `(and ,r ,s))
           (== q `(and ,w ,v))
           (implieso* r w)
           (implieso* s v))]
   [(fresh (r s)
           (== p `(or ,r ,s))
           (conde
            [(implieso r q)]
            [(implieso s q)]))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(< ,x (int ,n)))
           (== q `(< ,x (int ,m)))
           (<o n m))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(<= ,x (int ,n)))
           (== q `(<= ,x (int ,m)))
           (<=o n m))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(> ,x (int ,n)))
           (== q `(> ,x (int ,m)))
           (<o m n))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(>= ,x (int ,n)))
           (== q `(>= ,x (int ,m)))
           (<=o m n))]))

(define (implieso p q)
  (fresh (r t)
         (normo p r)
         (normo q t)
         (implieso* r t)))

(define (equivo p q)
  (fresh (r)
         (normo p r)
         (normo r q)))

;; p[x -> t] = q
(define (substo p x t q)
  (fresh (r)
         (substo* p x t r)
         (equivo r q)))

(define (provero p com q)
  (conde
   [(fresh (x e)
           (== com `(,x := ,e))
           (substo q x e p))]
   [(fresh (c1 r c2)
           (== com `(seq ,c1 ,c2))
           (provero p c1 r)
           (provero r c2 q))]
   [(fresh (cnd thn els)
           (== com `(if ,cnd ,thn ,els))
           (provero `(and ,p ,cnd) thn q)
           (provero `(and ,p (not ,cnd)) els q))]
   [(fresh (cnd body)
           (== com `(while ,cnd ,body))
           (equivo `(and ,p (not ,cnd)) q)
           (provero `(and ,p ,cnd) body p))]
   [(fresh (r com^)
           (== com `(pre ,r ,com^))
           (implieso p r)
           (provero r com^ Q))]
   [(fresh (r com^)
           (== com `(post ,r ,com^))
           (implieso r q)
           (provero p com^ r))]
   [(== com `(skip))
    (equivo p q)]))
