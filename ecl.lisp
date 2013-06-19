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

