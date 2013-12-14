(cl:in-package :versioned-function.internal)
(in-readtable :versioned-function)

(def-suite versioned-function)

(in-suite versioned-function)


(vfmakunbound 'foo)
(defvn foo (x) x)             
(defvn foo (x) (* x x))
(defvn foo (x &optional (n 100)) (* x x n))
(let ((foo 0))
  (defvn foo (x &optional (n 100)) (* x n foo)))

;(slot-value (find-class 'foo) 'history)
;(slot-value (find-class 'bar) 'history)

(defvn (bar a) (x) x)             
(defvn (bar b) (x) (* x x))
(defvn (bar c) (x &optional (n 100)) (* x x n))
(let ((foo 0))
  (defvn (bar d) (x &optional (n 100)) (* x n foo)))


(test versioned-function
  (let ((n (random 10)))
    (is-true (zerop (foo n)))
    (is-true (zerop (funcall #'foo n)))
    (is-true (zerop (funcall #'(foo 0) n)))
    ;; 
    (is-true (= (* n n 100) (funcall #'(foo 1) n)))
    (is-true (= (* n n) (funcall #'(foo 2) n)))
    (is-true (= n (funcall #'(foo 3) n))))
  (let ((n (random 10)))
    (is-true (zerop (bar n)))
    (is-true (zerop (funcall #'bar n)))
    (is-true (zerop (funcall #'(bar d) n)))
    ;; 
    (is-true (= (* n n 100) (funcall #'(bar c) n)))
    (is-true (= (* n n) (funcall #'(bar b) n)))
    (is-true (= n (funcall #'(bar a) n)))))


;;; *EOF*
