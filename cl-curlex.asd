;;;; cl-current-lexenv.asd

(asdf:defsystem #:cl-curlex
  :serial t
  :description "Leak *LEXENV* variable from compilation into runtime"
  :author "Alexander Popolitov <popolit@gmail.com>"
  :license "GPL"
  :components (#+sbcl(:file "sbcl")
		     #-(or sbcl)(:file "not-implemented")
	       (:file "package")))


