;;;; Backend for Clozure CL

(in-package "CCL")

(defnx1 nx1-fart-current-lexenv fart-current-lexenv context (&body body)
  (format t "current lexenv: ~a ~a~%" *nx-lexical-environment* (lexenv.functions *nx-lexical-environment*))
  (nx1-progn-body context body))

(export '(fart-current-lexenv))

(defnx1 nx1-with-current-lexenv with-current-lexenv context (&body body)
  (flet ((assoc-keys (alist)
	   (mapcar (lambda (x) (cons (car x) nil)) alist)))
    (nx1-progn-body context
		    `((let ((,(intern "*LEXENV*")
			     (%istruct 'lexical-environment
				       ,(lexenv.parent-env *nx-lexical-environment*)
				       (list ,@(lexenv.functions *nx-lexical-environment*))
				       (list ,@(lexenv.variables *nx-lexical-environment*))
				       nil
				       nil
				       nil
				       nil)))
			(declare (special ,(intern "*LEXENV*")))
			(declare (ignorable ,(intern "*LEXENV*")))
			,@body)))))

(export '(with-current-lexenv))

(defnx1 nx1-abbrolet abbrolet context ((&rest clauses) &body body)
  "Define abbreviations for macros and functions, defined in current lexenv."
  (let (res-macros res-funs)
    (dolist (clause clauses
	     (let ((new-env (new-lexical-environment *nx-lexical-environment*)))
	       (setf (lexenv.functions new-env) `(,.res-macros ,.(lexenv.functions new-env))
		     (lexenv.functions new-env) `(,.res-funs ,.(lexenv.functions new-env)))
	       (format t "successfully nooked functions and macros~%")
	       (let ((*nx-lexical-environment* new-env))
		 (format t "about to prognize~%")
		 (nx1-progn-body context body))))
      (destructuring-bind (short long) clause
	(let ((it (nx1-find-call-def long)))
	  (if it
	      (progn (format t "Pushing function~%")
		     (push `(,short function ,it) res-funs))
	      (let ((it (macro-function long)))
		(if it
		    (progn (format t "Pushing macro~%")
			   (push `(,short macro . ,it) res-macros))
		    (error "Name ~a does not designate any global or local function or macro" long)))))))))

(export '(abbrolet))


;; (in-package cl-curlex)

;; (defun foo ()
;;   (macrolet ((bar () 456))
;;     (flet ((bar1 () 123))
;;       (abbrolet ((foo1 bar))
;; 		(foo1)))))

