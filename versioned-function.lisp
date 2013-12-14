;;;; versioned-function.lisp

(cl:in-package :versioned-function.internal)


(defclass versioned-function-class (c2mop:funcallable-standard-class) 
  ((history :initform '() )))


(defmethod c2mop:validate-superclass ((c versioned-function-class)
                                      (sc c2mop:funcallable-standard-class))
  T)


(defclass versioning-function (c2mop:funcallable-standard-object)
  ((body :initarg :body))
  (:metaclass versioned-function-class))


(defmethod initialize-instance :after ((self versioning-function)
                                        &key definition-source lambda-list
                                       name)
  (declare (ignore definition-source lambda-list name))
  (c2mop:set-funcallable-instance-function self (slot-value self 'body)))

#|(remove-method #'initialize-instance
               (find-method #'initialize-instance (list :before) 
                            (mapcar #'find-class (list 'versioning-function))))|#


(defmethod make-instance :around ((class versioned-function-class) &key nick)
  (let ((inst (call-next-method)))
    (push (if nick (cons nick inst) (cons nil inst))
          (slot-value class 'history))
    inst))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun function-information* (name)
    (declare (ignorable name))
    #+sbcl (sb-cltl2:function-information name)
    #-sbcl (values nil nil nil)))


(defmacro define-versioned-function (name (&rest args) &body body)
  (destructuring-bind (name nick)
                      (if (consp name)
                          name
                          (list name nil))
   `(progn 
      (defclass ,name (versioning-function) 
        ((nick :initarg :nick))
        (:metaclass versioned-function-class))
      (declaim ,(multiple-value-bind (type localp decl)
                                     (function-information* name)
                  (declare (ignore type localp))
                  (if decl
                      (list 'ftype (cdar decl) name)
                      (list 'ftype 'function name))))
      (setf (fdefinition ',name) 
            (make-instance ',name
                           :body (lambda (,@args) ,@body)
                           :nick ',nick)))))


(defmacro defvn (name (&rest args) &body body)
  `(define-versioned-function ,name (,@args) ,@body))


;; The function VERSIONED-FUNCTION.INTERNAL::FOO-VERSIONED is undefined.

(define-condition undefined-versioned-function (undefined-function) 
  ((version :reader fversion :initarg :fversion))
  (:report
   (lambda (condition stream)
     (let ((*package* (find-package :keyword)))
       (format stream
               "The function (~S ~S) is undefined." 
               (cell-error-name condition)
               (fversion condition))))))


(defun vfunction* (name &optional (version 0))
  (let* ((class (find-class name nil))
         (fn (cdr (etypecase version
                    (integer (nth version (slot-value class 'history)))
                    (symbol (assoc version 
                                   (slot-value  class 'history)))))))
    (or (and class fn)
        (error 'undefined-versioned-function 
               :arguments (list version)
               :name name
               :fversion version))))


(defmacro vfunction (name &optional (version 0))
  `(vfunction* ',name ',version))


(defun vfmakunbound (name)
  (let ((c (find-class name nil)))
    (and c (setf (slot-value c 'history) '() )))
  (fmakunbound name))


;;; *EOF*
