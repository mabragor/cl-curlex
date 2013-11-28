;;;; Backend for Clozure CL

(in-package "CCL")

(defnx1 nx1-fart-current-lexenv fart-current-lexenv context (&body body)
  (format t "current lexenv: ~a ~a~%" *nx-lexical-environment* (lexenv.functions *nx-lexical-environment*))
  (nx1-progn-body context body))

(export '(fart-current-lexenv))

(defun assoc-keys (alist)
  (mapcar (lambda (x) (cons (car x) nil)) alist))

(defun sanitize-lexenv (lexenv)
  `(%istruct 'lexical-environment
	     ,(lexenv.parent-env lexenv)
	     (list ,@(lexenv.functions lexenv))
	     (list ,@(lexenv.variables lexenv))
	     nil
	     nil
	     nil
	     nil))

(defun cc-sanitize-lexenv (lexenv)
  (%istruct 'lexical-environment
	    (lexenv.parent-env lexenv)
	    (lexenv.functions lexenv)
	    (lexenv.variables lexenv)
	    nil
	    nil
	    nil
	    nil))
  

(defnx1 nx1-with-current-lexenv with-current-lexenv context (&body body)
  (nx1-progn-body context
		  `((let ((,(intern "*LEXENV*") ,(sanitize-lexenv *nx-lexical-environment*)))
		      (declare (special ,(intern "*LEXENV*")))
		      (declare (ignorable ,(intern "*LEXENV*")))
		      ,@body))))

(defmacro with-current-cc-lexenv (&body body)
  `(let ((,(intern "*LEXENV*") (cc-sanitize-lexenv *nx-lexical-environment*)))
     (declare (special ,(intern "*LEXENV*")))
     (declare (ignorable ,(intern "*LEXENV*")))
     ,@body))

(export '(with-current-lexenv with-current-cc-lexenv))

(defnx1 nx1-abbrolet abbrolet context ((&rest clauses) &body body)
  "Define abbreviations for macros and functions, defined in current lexenv."
  (let (res-macros res-funs)
    (dolist (clause clauses
	     (let ((new-env (new-lexical-environment *nx-lexical-environment*)))
	       (setf (lexenv.functions new-env) `(,.res-macros ,.(lexenv.functions new-env))
		     (lexenv.functions new-env) `(,.res-funs ,.(lexenv.functions new-env)))
	       (let ((*nx-lexical-environment* new-env))
		 (nx1-progn-body context body))))
      (destructuring-bind (short long) clause
	(let ((it (nx1-find-call-def long)))
	  (if it
	      (push `(,short function ,it . ,long) res-funs)
	      (let ((it (macro-function long *nx-lexical-environment*)))
		(if it
		    (push `(,short macro . ,it) res-macros)
		    (error "Name ~a does not designate any global or local function or macro" long)))))))))

(export '(abbrolet))


;; (in-package cl-curlex)

;; (defun foo ()
;;   (macrolet ((bar () 456))
;;     (flet ((bar1 () 123))
;;       (abbrolet ((foo1 bar))
;; 		(foo1)))))

