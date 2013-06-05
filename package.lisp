;;;; package.lisp

(defpackage #:cl-curlex
  #+sbcl(:use #:cl #:sb-c)
  (:export #:with-current-lexenv #:fart-current-lexenv))

