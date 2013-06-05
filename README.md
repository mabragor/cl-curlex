cl-curlex
===========

Leak *LEXENV* variable which describes current lexical environment into body of a call.

Basic example:

        CL-USER> (ql:quickload 'cl-curlex)
        CL-USER> (cl-curlex:with-current-lexenv *lexenv*)
        #S(SB-KERNEL:LEXENV
	:FUNS NIL
        :VARS NIL
        :BLOCKS NIL
        :TAGS NIL
        :TYPE-RESTRICTIONS NIL
        :LAMBDA #<SB-C::CLAMBDA
                  :%SOURCE-NAME SB-C::.ANONYMOUS.
                  :%DEBUG-NAME (LAMBDA ())
                  :KIND NIL
                  :TYPE #<SB-KERNEL:FUN-TYPE (FUNCTION NIL (VALUES T &OPTIONAL))>
                  :WHERE-FROM :DEFINED
                  :VARS NIL {AE26BA9}>
        :CLEANUP NIL
        :HANDLED-CONDITIONS NIL
        :DISABLED-PACKAGE-LOCKS NIL
        :%POLICY ((COMPILATION-SPEED . 1) (DEBUG . 1) (INHIBIT-WARNINGS . 1)
                  (SAFETY . 1) (SPACE . 1) (SPEED . 1))
        :USER-DATA NIL)

Slightly more sophisticated:

        CL-USER> (let ((a 1)) (cl-curlex:with-current-lexenv (let ((b 1)) *lexenv*)))
        #S(SB-KERNEL:LEXENV
           :FUNS NIL
           :VARS ((A . #<SB-C::LAMBDA-VAR :%SOURCE-NAME A {AEA1371}>))
           :BLOCKS NIL
           :TAGS NIL
           :TYPE-RESTRICTIONS NIL
           :LAMBDA #<SB-C::CLAMBDA
                     :%SOURCE-NAME SB-C::.ANONYMOUS.
                     :%DEBUG-NAME (LET ((A 1))
                                    )
                     :KIND :ZOMBIE
                     :TYPE #<SB-KERNEL:BUILT-IN-CLASSOID FUNCTION (read-only)>
                     :WHERE-FROM :DEFINED
                     :VARS (A) {AEA14B1}>
           :CLEANUP NIL
           :HANDLED-CONDITIONS NIL
           :DISABLED-PACKAGE-LOCKS NIL
           :%POLICY ((COMPILATION-SPEED . 1) (DEBUG . 1) (INHIBIT-WARNINGS . 1)
                     (SAFETY . 1) (SPACE . 1) (SPEED . 1))
           :USER-DATA NIL)

Package exports two macro - FART-CURRENT-LEXENV which simply prints current lexenv, but not leaks it into its body
and WITH-CURRENT-LEXENV, which leaks *LEXENV* variable into its body.

N.B.: leaking is for reading purposes only, and *LEXENV* captures state of lexical environment as it were on enter
to WITH-CURRENT-LEXENV, not as it is when *LEXENV* var is used - this is why in the "sophisticated" example
B variable is not seen in *LEXENV* - it was not there, when we entered WITH-CURRENT-LEXENV, it was binded somewhere
inside.

N.B.: Although the ultimate goal is to leak lexenv in all major implementations, the form of a *LEXENV*
will be (intentionally) implementation specific.

TODO:
  - support major CL implementations
    - SBCL : lexenv capture is not full, only names of functions, variables and so on are captured,
      advanced features like package locks and policies are not captured
    - (wont, don't have an access to sources or other spec of non-standard features) Allegro
    - CLISP
    - CMUCL
    - ECL
    - LispWorks - probably won't have the sources either
    - OpenMCL
