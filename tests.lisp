(in-package :cl-user)

(defpackage :cl-curlex-tests
  (:use :cl :cl-curlex :eos :iterate)
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
		 #+ecl compiler::cmp-env-variables
		 #+ccl ccl::lexenv.variables
		 *lexenv*))))

(test simple
  (is (equal '((b) (a)) #-ccl(iter (for elt in (foo))
				   (if (find (car elt) '(b a))
				       (collect (list (car elt)))))
	     #+ccl (mapcar (lambda (x)
			     (list (ccl::var-name x)))
			   (foo))
	     )))
  
#+sbcl
(defun abbro-foo ()
  (macrolet ((bar () 456))
    (abbrolet ((foo bar))
	      (foo))))

#+sbcl
(test abbrolet-with-macrolet
  (is (equal 456
	     (abbro-foo))))