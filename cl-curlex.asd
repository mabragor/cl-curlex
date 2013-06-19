;;;; cl-current-lexenv.asd

(defpackage :cl-curlex-system
  (:use :cl :asdf))

(in-package cl-curlex-system)


(defsystem #:cl-curlex
  :serial t
  :version "0.2"
  :description "Leak *LEXENV* variable from compilation into runtime"
  :author "Alexander Popolitov <popolit@gmail.com>"
  :license "GPL"
  :components (#+sbcl(:file "sbcl")
		     #+cmucl(:file "cmucl")
		     #-(or sbcl cmucl)(:file "not-implemented")
	       (:file "package")))

(defsystem :cl-curlex-tests
  :description "Tests for CL-CURLEX."
  :licence "GPL"
  :depends-on (:cl-curlex :eos)
  :components ((:file "tests")))

(defmethod perform ((op test-op) (sys (eql (find-system :cl-curlex))))
  (load-system :cl-curlex-tests)
  (funcall (intern "RUN-TESTS" :cl-curlex-tests)))
