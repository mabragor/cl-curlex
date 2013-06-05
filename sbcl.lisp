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
