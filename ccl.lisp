;;;; Backend for Clozure CL

(in-package "CCL")

(defnx1 nx1-fart-current-lexenv fart-current-lexenv context (&body body)
  (format t "current lexenv: ~a~%" *nx-lexical-environment*)
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

(in-package cl-user)

