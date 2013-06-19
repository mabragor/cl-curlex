(in-package :cl-user)

(defpackage :cl-curlex-tests
  (:use :cl :cl-curlex :eos)
  (:export #:run-tests))

(in-package :cl-curlex-tests)

(def-suite curlex)
(in-suite curlex)

(defun run-tests ()
  (let ((results (run 'curlex)))
    (eos:explain! results)
    (unless (eos:results-status results)
      (error "Tests failed."))))

(defun foo ()
  (let ((a 1) (b 2))
    (declare (ignorable a b))
    (with-current-lexenv
	(#+cmucl c::lexenv-variables
		 #+sbcl sb-c::lexenv-vars
		 *lexenv*))))

(test simple
  (is (equal '((b) (a)) (foo))))
  
