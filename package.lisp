;;;; package.lisp

(defpackage #:cl-curlex
  #+sbcl(:use #:cl #:sb-c)
  #+cmucl(:use #:cl #:c)
  (:export #:with-current-lexenv #:fart-current-lexenv))

