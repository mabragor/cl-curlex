;;;; cl-current-lexenv.asd

(asdf:defsystem #:cl-current-lexenv
  :serial t
  :description "Leak *LEXENV* variable from compilation into runtime"
  :author "Alexander Popolitov <popolit@gmail.com>"
  :license "GPL"
  :components ((:file "package")
               (:file "cl-current-lexenv")))

