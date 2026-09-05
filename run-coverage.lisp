(require :asdf)
(require :sb-cover)

(defparameter *timeout-seconds* 120)

(defun script-directory ()
  (make-pathname :name nil :type nil
                 :defaults (or *load-truename*
                              *compile-file-truename*
                              (error "Unable to determine the script location"))))

(defun configure-source-registry (root)
  "Prepend ROOT and its dependencies to CL_SOURCE_REGISTRY."
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

;; The default suite excludes FFI calls that require a real display; those
;; calls are exercised by cl-glfw3-kit/hardware-test.
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
