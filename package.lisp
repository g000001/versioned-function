;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :versioned-function
  (:use)
  (:export :define-versioned-function
           :defvn
           :vfmakunbound
           :vfunction))

(defpackage :versioned-function.internal
  (:use :versioned-function :cl :named-readtables :fiveam))

