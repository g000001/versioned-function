;;;; versioned-function.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :versioned-function
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :named-readtables
               :closer-mop
               #+sbcl :sb-cltl2)
  :components ((:file "package")
               (:file "versioned-function")
               (:file "readtable")
               (:file "test")))

(defmethod perform ((o test-op) (c (eql (find-system :versioned-function))))
  (load-system :versioned-function)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :versioned-function.internal :versioned-function))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

