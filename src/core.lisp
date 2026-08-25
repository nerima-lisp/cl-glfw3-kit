;;;; src/core.lisp
(in-package #:cl-glfw3-kit)

(defparameter +version+ "0.2.0"
  "Kept in sync with cl-glfw3-kit.asd's :version by hand; see release.yml,
which refuses to publish a tag that disagrees with the .asd.")

(defun library-version ()
  "Return this Lisp package's own version string -- distinct from
GLFW-VERSION-STRING, the underlying GLFW C library's version."
  +version+)
