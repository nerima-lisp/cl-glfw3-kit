;;;; src/conditions.lisp
(in-package #:cl-glfw3-kit)

(define-condition cl-glfw3-kit-error (error) ()
  (:documentation "Base condition for every error this library signals."))
