(in-package #:cl-glfw3-kit)

(defparameter +version+ "0.2.0"
  "Package version; kept in sync with cl-glfw3-kit.asd's :version.")

(defun library-version ()
  "Return this Lisp package's own version string -- distinct from
GLFW-VERSION-STRING, the underlying GLFW C library's version."
  +version+)
