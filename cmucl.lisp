;;;; Backend for SBCL

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

  (export '(with-current-lexenv)))
