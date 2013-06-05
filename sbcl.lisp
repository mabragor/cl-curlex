;;;; Backend for SBCL

(in-package #:sb-c)

(def-ir1-translator fart-current-lexenv ((&body body) start next result)
  (format t "current lexenv: ~a~%" *lexenv*)
  (ir1-convert-progn-body start next result body))

(export '(fart-current-lexenv))

(def-ir1-translator with-current-lexenv ((&body body) start next result)
  (ir1-convert start next result `(let ((,(intern "*LEXENV*") ,*lexenv*))
				    (declare (special ,(intern "*LEXENV*")))
				    (declare (ignorable ,(intern "*LEXENV*")))
				    ,@body)))

(export '(with-current-lexenv))
