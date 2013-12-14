;;;; readtable.lisp

(cl:in-package :versioned-function.internal)
(in-readtable :common-lisp)

(defreadtable :versioned-function
  (:merge :standard)
  (:dispatch-macro-char #\# #\' (lambda (stream char arg)
                                  (declare (ignore char arg))
                                  (let ((fname (read stream)))
                                    (etypecase fname
                                      ((OR SYMBOL (CONS (EQL CL:SETF) *))
                                       `(function ,fname))
                                      (CONS `(vfunction ,@fname))))))
  (:case :upcase))



