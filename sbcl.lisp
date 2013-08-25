;;;; Backend for SBCL

(in-package #:sb-c)

(def-ir1-translator fart-current-lexenv ((&body body) start next result)
  (format t "current lexenv: ~a~%" *lexenv*)
  (ir1-convert-progn-body start next result body))

(export '(fart-current-lexenv))

(def-ir1-translator with-current-lexenv ((&body body) start next result)
  (flet ((assoc-keys (alist)
	   (mapcar (lambda (x) (cons (car x) nil)) alist)))
    (ir1-convert start next result `(let ((,(intern "*LEXENV*")
					   (internal-make-lexenv ',(assoc-keys (lexenv-funs *lexenv*))
								 ',(assoc-keys (lexenv-vars *lexenv*))
								 ',(assoc-keys (lexenv-blocks *lexenv*))
								 ',(assoc-keys (lexenv-tags *lexenv*))
								 ',(lexenv-type-restrictions *lexenv*)
								 nil
								 nil
								 nil
								 nil
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
				      (declare (ignorable ,(intern "*LEXENV*")))
				      ,@body))))

(export '(with-current-lexenv))

(def-ir1-translator abbrolet (((&rest clauses) &body body) start next result)
  "Define abbreviations for macros and functions, defined in current lexenv."
  (let (res)
    (dolist (clause clauses
	     (let ((*lexenv* (make-lexenv :funs (nconc res (lexenv-funs *lexenv*)))))
	       (ir1-convert-progn-body start next result body)))
      (destructuring-bind (short long) clause
	(let ((it (assoc long (lexenv-funs *lexenv*))))
	  (if it
	      (push `(,short . ,(cdr it)) res)
	      (let ((it (macro-function long)))
		(if it
		    (push `(,short macro . ,it) res)
		    (if (fboundp long)
			(push `(,short . ,(fdefinition long)) res)
			(error "Name ~a does not designate any global or local function or macro" long))))))))))

(export '(abbrolet))
