;;; Backend for ECL

(in-package "COMPILER")

(defun c1fart-current-lexenv (args)
  ;; (check-args-number 'FART-CURRENT-LEXENV args 1)
  (format t "~a~%" *cmp-env*)
  (c1progn args))

(setf (gethash 'fart-current-lexenv *c1-dispatch-table*) 'c1fart-current-lexenv)
(setf (gethash 'fart-current-lexenv *t1-dispatch-table*) 'c1fart-current-lexenv)

(export '(fart-current-lexenv))

(defun c1with-current-lexenv (body)
  (c1expr `(let ((,(intern "*LEXENV*")
		  ',(destructuring-bind (vars . funs) *cmp-env*
					(cons (mapcar #'butlast
						      (remove-if (lambda (x)
								   (or (not (consp x))
								       (equal (car x) :declare)))
								 vars))
					      (mapcar #'butlast (remove-if-not #'consp funs))))))
	     (declare (special ,(intern "*LEXENV*")))
	     (declare (ignorable ,(intern "*LEXENV*")))
	     ,@body)))

(setf (gethash 'with-current-lexenv *c1-dispatch-table*) 'c1with-current-lexenv)
(setf (gethash 'with-current-lexenv *t1-dispatch-table*) 'c1with-current-lexenv)

(export '(with-current-lexenv))

(defun c1abbrolet (args)
  "Define abbreviations for macros and functions, defined in current lexenv."
  (destructuring-bind ((&rest clauses) &body body) args
    (let (res-macros res-funs)
      (dolist (clause clauses
	       (let* ((*lexenv* (make-lexenv :funs res-macros))
		      (*lexenv* (make-lexenv :funs res-funs)))
		 (ir1-convert-progn-body start next result body)))
	(destructuring-bind (short long) clause
	  (let ((it (assoc long (lexenv-funs *lexenv*))))
	    (if it
		(if (and (consp (cdr it)) (eq (cadr it) 'macro))
		    (push `(,short . ,(cdr it)) res-macros)
		    (push `(,short . ,(cdr it)) res-funs))
		(let ((it (macro-function long)))
		  (if it
		      (push `(,short macro . ,it) res-macros)
		      (if (fboundp long)
			  (let ((it (find-free-fun long "shouldn't happen (no c-macro)")))
			    (push `(,short . ,it) res-funs))
			  (error "Name ~a does not designate any global or local function or macro" long))))))))))

(setf (gethash 'abbrolet *c1-dispatch-table*) 'c1abbrolet)
(setf (gethash 'abbrolet *t1-dispatch-table*) 'c1abbrolet)

(export '(abbrolet))
