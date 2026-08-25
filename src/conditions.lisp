;;;; src/conditions.lisp
(in-package #:cl-glfw3-kit)

(define-condition cl-glfw3-kit-error (error) ()
  (:documentation "Base condition for every error this library signals. Never
signalled directly -- only its situational subtypes below are, each with
its own :REPORT -- so it carries none of its own, matching
CODING_STANDARD.md's own base-condition example."))

(defmacro define-glfw-error-condition (name)
  "Define NAME as a situational CL-GLFW3-KIT-ERROR subtype carrying the
description string GLFW itself reported for the error. The fourteen GLFW
error situations share this one shape (a single DESCRIPTION slot and a
report that names the situation), so the shape is written once here and
each situation supplies only its name -- see *GLFW-ERROR-CONDITIONS* in
constants.lisp for the GLFW error code each NAME corresponds to."
  (let ((reader (intern (format nil "~A-DESCRIPTION" name))))
    `(define-condition ,name (cl-glfw3-kit-error)
       ((description :initarg :description :initform "" :reader ,reader))
       (:report (lambda (condition stream)
                  (format stream "~(~A~): ~A" ',name (,reader condition)))))))

(define-glfw-error-condition glfw-not-initialized)
(define-glfw-error-condition glfw-no-current-context)
(define-glfw-error-condition glfw-invalid-enum)
(define-glfw-error-condition glfw-invalid-value)
(define-glfw-error-condition glfw-out-of-memory)
(define-glfw-error-condition glfw-api-unavailable)
(define-glfw-error-condition glfw-version-unavailable)
(define-glfw-error-condition glfw-platform-error)
(define-glfw-error-condition glfw-format-unavailable)
(define-glfw-error-condition glfw-no-window-context)
(define-glfw-error-condition glfw-cursor-unavailable)
(define-glfw-error-condition glfw-feature-unavailable)
(define-glfw-error-condition glfw-feature-unimplemented)
(define-glfw-error-condition glfw-platform-unavailable)

(define-condition glfw-unknown-error (cl-glfw3-kit-error)
  ((code :initarg :code :initform 0 :reader glfw-unknown-error-code)
   (description :initarg :description :initform "" :reader glfw-unknown-error-description))
  (:report (lambda (condition stream)
             (format stream "Unrecognized GLFW error ~D: ~A"
                     (glfw-unknown-error-code condition)
                     (glfw-unknown-error-description condition))))
  (:documentation "Signaled only if a future GLFW release reports an error
code absent from *GLFW-ERROR-CONDITIONS* (all fourteen GLFW 3.4 codes are
covered) -- unreachable against the GLFW version this library targets."))
