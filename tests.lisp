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
  
#+(or sbcl cmucl ecl ccl)
(defun abbro-macrolet ()
  (macrolet ((bar () 456))
    (abbrolet ((foo bar))
	      (foo))))
#+(or sbcl cmucl ecl ccl)
(defun abbro-flet ()
  (flet ((bar () 456))
    (abbrolet ((foo bar))
	      (foo))))
#+(or sbcl cmucl ecl ccl)
(defun abbro-labels ()
  (labels ((bar () 456))
    (abbrolet ((foo bar))
	      (foo))))


(defun model-global-function ()
  123)
(defmacro model-global-macro ()
  123)

#+(or sbcl cmucl ecl ccl)
(test abbrolet-macrolet
  (is (equal 456 (abbro-macrolet))))

(test abbrolet-flet
  (is (equal 456 (abbro-flet))))
(test abbrolet-labels
  (is (equal 456 (abbro-labels))))

#+(or sbcl cmucl ecl ccl)
(test abbrolet-defmacro
  (is (equal 123
	     (abbrolet ((foo model-global-macro))
		       (foo)))))

(test abbrolet-defun)

#+(or sbcl cmucl)
(test abbrolet-defun
      (is (equal 123
		 (abbrolet ((foo model-global-function))
			   (foo)))))
