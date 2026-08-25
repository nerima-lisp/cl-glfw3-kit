;;;; run-coverage.lisp
;;;
;;; Bootstrap script: instruments cl-glfw3-kit with SBCL's sb-cover and runs
;;; the suite through cl-weave's native coverage gate (RUN-ALL :COVERAGE T),
;;; which fails the build if expression/branch coverage regresses below the
;;; floor below.
;;;
;;; 100% is not the target: DEFCONSTANT/DEFSTRUCT slot lists/DEFPACKAGE
;;; export lists/IN-PACKAGE forms and DEFMACRO bodies have no runtime
;;; execution model for sb-cover to observe, confirmed by direct experiment
;;; (cl-log-kit's own run-coverage.lisp documents the same finding). This
;;; library's define-glfw-function macro is deliberately restricted to
;;; behavioural codegen -- it emits an ordinary DEFUN per binding rather
;;; than embedding the float-trap-mask/error-check logic in the macro body
;;; itself -- which is what keeps that logic inside sb-cover's reach at
;;; all. The other, larger source of permanently uncovered spans here is
;;; specific to an FFI binding: every function that touches a real
;;; GLFWwindow*/GLFWmonitor* pointer directly (window property accessors,
;;; input queries, context/frame-loop functions, VIDEO-MODE) is excluded
;;; from src/'s own coverage instrumentation path and exercised instead by
;;; cl-glfw3-kit/hardware-test (t/hardware/hardware-test.lisp), which needs
;;; a real display `nix flake check`'s sandbox does not have -- see that
;;; system and cl-glfw3-kit.asd for the split. Raising
;;; *coverage-minimum-expression*/*coverage-minimum-branch* below requires
;;; new evidence of closeable gaps, stated in the pull request, not a quiet
;;; edit here.
;;; Usage: sbcl --script run-coverage.lisp
(require :asdf)
(require :sb-cover)

(defparameter *timeout-seconds* 120)

(defun script-directory ()
  (make-pathname :name nil :type nil
                 :defaults (or *load-truename*
                              *compile-file-truename*
                              (error "Unable to determine the script location"))))

(defun configure-source-registry (root)
  "Prepend ROOT and its sibling checkouts to CL_SOURCE_REGISTRY, preserving
its existing configuration."
  (let* ((entries (list root
                        (merge-pathnames #P"../cl-weave/" root)
                        (merge-pathnames #P"../cl-boundary-kit/" root)
                        (merge-pathnames #P"../cl-host-kit/" root)))
         (local-registry (format nil "~{~A//:~}" (mapcar #'namestring entries)))
         (existing (uiop:getenv "CL_SOURCE_REGISTRY"))
         (combined (if (and existing (plusp (length existing)))
                      (format nil "~A~A" local-registry existing)
                      local-registry)))
    (setf (uiop:getenv "CL_SOURCE_REGISTRY") combined)
    (asdf:initialize-source-registry)))

;; Measured directly (see coverage/cover-index.html after a run): 43.93%
;; expression, 42.86% branch. constants.lisp and package.lisp read as 0%
;; not because they are untested but because they are pure data
;; (DEFPARAMETER tables, DEFPACKAGE/IN-PACKAGE) -- sb-cover has no runtime
;; execution model for a form that never does anything but bind a value at
;; load time, the same category cl-log-kit's own run-coverage.lisp
;; documents. callbacks.lisp/context.lisp/input.lisp/monitor.lisp read low
;; because most of their logic is exactly the FFI calls
;; cl-glfw3-kit/hardware-test exists to cover instead (see that system and
;; its own 9/9 passing suite) -- deliberately excluded from THIS
;; instrumentation run, which only loads cl-glfw3-kit/test, not
;; cl-glfw3-kit/hardware-test, because `nix flake check`'s sandbox can
;; only ever run the former. These floors sit just below that measurement
;; so ordinary sb-cover accounting variance cannot trip the gate
;; spuriously, while still catching a real regression.
(defparameter *coverage-minimum-expression* 43.0)
(defparameter *coverage-minimum-branch* 42.0)

(let* ((root (script-directory))
       (src-dir (merge-pathnames #P"src/" root))
       (coverage-dir (merge-pathnames #P"coverage/" root))
       (coverage-index (merge-pathnames #P"cover-index.html" coverage-dir)))
  (configure-source-registry root)

  (proclaim '(optimize sb-cover:store-coverage-data))
  (handler-bind ((warning #'muffle-warning))
    (asdf:load-system "cl-glfw3-kit" :force t))
  (proclaim '(optimize (sb-cover:store-coverage-data 0)))

  (handler-bind ((warning #'muffle-warning))
    (asdf:load-system "cl-glfw3-kit/test"))

  (handler-case
      (unless (sb-ext:with-timeout *timeout-seconds*
                (uiop:symbol-call :cl-weave :run-all
                                  :reporter :spec
                                  :coverage t
                                  :coverage-reset nil
                                  :coverage-report-directory coverage-dir
                                  :coverage-include-pathnames (list src-dir)
                                  :coverage-minimum-expression *coverage-minimum-expression*
                                  :coverage-minimum-branch *coverage-minimum-branch*))
        (format *error-output* "~&run-coverage.lisp: cl-glfw3-kit test suite failed~%")
        (uiop:quit 1))
    (sb-ext:timeout ()
      (format *error-output*
              "~&run-coverage.lisp: exceeded ~Ds timeout~%" *timeout-seconds*)
      (uiop:quit 1))
    (error (condition)
      (format *error-output* "~&run-coverage.lisp: ~A~%" condition)
      (uiop:quit 1)))

  (format t "~&Coverage report: ~A~%" (namestring coverage-index))
  (uiop:quit 0))
