;;;; t/package.lisp
(defpackage #:cl-glfw3-kit/test
  (:use #:cl)
  (:shadowing-import-from #:cl-weave #:describe)
  (:import-from #:cl-weave #:it #:expect #:signals #:run-all)
  (:import-from #:cl-glfw3-kit #:library-version #:cl-glfw3-kit-error)
  (:export #:run-tests))

(in-package #:cl-glfw3-kit/test)

(defun run-tests (&key (reporter :spec))
  (unless (run-all :reporter reporter :timeout-ms 20000)
    (error "cl-glfw3-kit test suite failed"))
  (format t "~&cl-glfw3-kit/test: successful completion with 0 failures~%")
  t)
