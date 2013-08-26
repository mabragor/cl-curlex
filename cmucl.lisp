;;;; Backend for CMUCL

(in-package #:c)

(ext:without-package-locks

  (def-ir1-translator fart-current-lexenv ((&body body) start cont)
    (format t "current lexenv: ~a~%" *lexical-environment*)
    (ir1-convert-progn-body start cont body))

  (export '(fart-current-lexenv))

  (def-ir1-translator with-current-lexenv ((&body body) start cont)
    (flet ((assoc-keys (alist)
	     (mapcar (lambda (x) (cons (car x) nil)) alist)))
      (ir1-convert start cont
		   `(let ((,(intern "*LEXENV*")
			   (internal-make-lexenv
			    ',(assoc-keys (lexenv-functions *lexical-environment*))
			    ',(assoc-keys (lexenv-variables *lexical-environment*))
			    ',(assoc-keys (lexenv-blocks *lexical-environment*))
			    ',(assoc-keys (lexenv-tags *lexical-environment*))
			    ',(lexenv-type-restrictions *lexical-environment*)
			    nil
			    nil
			    *default-cookie*
			    *default-interface-cookie*
			    nil
			    nil
			    ;; ,(lexenv-lambda *lexenv*)
			    ;; ,(lexenv-cleanup *lexenv*)
			    ;; ',(lexenv-handled-conditions *lexenv*)
			    ;; ,(lexenv-disabled-package-locks *lexenv*)
			    ;; ',(lexenv-%policy *lexenv*)
			    ;; ',(lexenv-user-data *lexenv*))))
			    )))
		      (declare (special ,(intern "*LEXENV*")))
		      ;; CMUCL error's when special variables are declared ignorable
		      ;; (declare (ignorable ,(intern "*LEXENV*")))
		      ,@body))))

  (export '(with-current-lexenv))

  (def-ir1-translator abbrolet (((&rest clauses) &body body) start cont)
    "Define abbreviations for macros and functions, defined in current lexenv."
    (let (res-macros res-funs)
      (dolist (clause clauses
	       (let* ((*lexical-environment* (make-lexenv :functions res-macros))
		      (*lexical-environment* (make-lexenv :functions res-funs)))
		 (ir1-convert-progn-body start cont body)))
	(destructuring-bind (short long) clause
	  (let ((it (assoc long (lexenv-functions *lexical-environment*)
			   ;; In CMUCL keys of this assoc list may be complex
			   :test (lambda (x y)
				   (if (consp y)
				       (eq x (cadr y))
				       (eq x y))))))
	    (if it
		(if (and (consp (cdr it)) (eq (cadr it) 'macro))
		    (push `(,short . ,(cdr it)) res-macros)
		    (push `(,short . ,(cdr it)) res-funs))
		(let ((it (macro-function long)))
		  (if it
		      (push `(,short macro . ,it) res-macros)
		      (if (fboundp long)
			  (let ((it (find-free-function long "shouldn't happen (no c-macro)")))
			    (push `(,short . ,it) res-funs))
			  (error "Name ~a does not designate any global or local function or macro" long))))))))))

  (export '(abbrolet))
  )
