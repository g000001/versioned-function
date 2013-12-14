(cl:in-package :versioned-function.internal)
(in-readtable :versioned-function)


(vfmakunbound 'fib)

(declaim (ftype (function (fixnum) (values fixnum &optional)) fib))


(define-versioned-function fib (n)
  (if (< n 2)
      n
      (+ (fib (1- n))
         (fib (- n 2)))))


(fib 30)
;⇒ 832040
#|------------------------------------------------------------|
Evaluation took:
  0.049 seconds of real time
  0.048003 seconds of total run time (0.048003 user, 0.000000 system)
  97.96% CPU
  117,186,759 processor cycles
  0 bytes consed
  
Intel(R) Core(TM)2 Duo CPU     P8600  @ 2.40GHz
 |------------------------------------------------------------|#


(define-versioned-function (fib fast) (n)
  (declare (optimize (safety 0) (speed 3)))
  (declare (fixnum n))
  (if (< n 2)
      n
      (the fixnum
           (+ (fib (1- n))
              (fib (- n 2))))))

(fib 30)
;⇒ 832040
#|------------------------------------------------------------|
Evaluation took:
  0.026 seconds of real time
  0.024002 seconds of total run time (0.024002 user, 0.000000 system)
  92.31% CPU
  61,656,543 processor cycles
  0 bytes consed
  
Intel(R) Core(TM)2 Duo CPU     P8600  @ 2.40GHz
 |------------------------------------------------------------|#

(disassemble #'fib) or
(disassemble #'(fib 0)) or
(disassemble #'(fib fast))
;>>  ; disassembly for (LAMBDA (N) :IN "/l/src/rw/versioned-function/demo.lisp")
;>>  ; Size: 187 bytes
;>>  ; 180E0590:       .ENTRY (LAMBDA (N) :IN "/l/src/rw/versioned-function/demo.lisp")(N)  ; (FUNCTION
;>>                                                                                         ;  (FIXNUM) ..)
;>>  ;      5C8:       8F4508           POP QWORD PTR [RBP+8]
;>>  ;      5CB:       488D65F0         LEA RSP, [RBP-16]
;>>  ;      5CF:       488BF2           MOV RSI, RDX
;>>  ;      5D2:       4883FE04         CMP RSI, 4
;>>  ;      5D6:       7C6E             JL L1
;>>  ;      5D8:       488975F0         MOV [RBP-16], RSI
;>>  ;      5DC:       488BD6           MOV RDX, RSI
;>>  ...
;=>  NIL


(disassemble #'(fib 1))
;>>  ; disassembly for (LAMBDA (N) :IN "/l/src/rw/versioned-function/demo.lisp")
;>>  ; Size: 376 bytes
;>>  ; 17E92A50:       .ENTRY (LAMBDA (N) :IN "/l/src/rw/versioned-function/demo.lisp")(N)  ; (FUNCTION
;>>                                                                                         ;  (T) ..)
;>>  ;      A88:       8F4508           POP QWORD PTR [RBP+8]
;>>  ;      A8B:       488D65F0         LEA RSP, [RBP-16]
;>>  ;      A8F:       4883F902         CMP RCX, 2
;>>  ;      A93:       0F852A010000     JNE L7
;>>  ;      A99:       488955F8         MOV [RBP-8], RDX
;>>  ;      A9D:       498B442450       MOV RAX, [R12+80]
;>>  ;      AA2:       4883C010         ADD RAX, 16
;>>  ;      AA6:       48C740F851000000 MOV QWORD PTR [RAX-8], 81
;>>  ;      AAE:       488968F0         MOV [RAX-16], RBP
;>>  ;      AB2:       4989442450       MOV [R12+80], RAX
;>>  ;      AB7:       488B55F8         MOV RDX, [RBP-8]
;>>  ;      ABB:       BF04000000       MOV EDI, 4
;>>  ...
;=>  NIL




(disassemble (vfunction fib))

(vfunction fib)
;=>  #<FIB {1020CFCCCB}>

(funcall #'(fib 0) 10)
;=>  55
