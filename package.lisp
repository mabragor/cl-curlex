;;;; package.lisp

(defpackage #:cl-curlex
  (:use #:cl #+sbcl #:sb-c
	#+cmucl #:c
	#+ecl #:compiler)
  (:export #:with-current-lexenv #:fart-current-lexenv))

