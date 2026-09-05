(in-package #:cl-glfw3-kit)

(define-glfw-function %glfw-init "glfwInit" sb-alien:int)
(define-glfw-function %glfw-terminate "glfwTerminate" sb-alien:void)
(define-glfw-function %glfw-get-version "glfwGetVersion" sb-alien:void
  (major (* sb-alien:int)) (minor (* sb-alien:int)) (revision (* sb-alien:int)))
(define-glfw-function glfw-version-string "glfwGetVersionString" sb-alien:c-string)
(define-glfw-function %glfw-set-error-callback "glfwSetErrorCallback" (* t)
  (callback (* t)))

(defun glfw-version ()
  "Return (VALUES MAJOR MINOR REVISION) for the underlying GLFW C library --
distinct from LIBRARY-VERSION, which is this Lisp package's own semver."
  (sb-alien:with-alien ((major sb-alien:int) (minor sb-alien:int) (revision sb-alien:int))
    (%glfw-get-version (sb-alien:addr major) (sb-alien:addr minor) (sb-alien:addr revision))
    (values major minor revision)))

(defvar *init-function* #'%glfw-init
  "The function CALL-WITH-GLFW calls to initialize GLFW.")

(defvar *terminate-function* #'%glfw-terminate
  "The function CALL-WITH-GLFW calls to shut GLFW down.")

(defun call-with-glfw (continuation)
  "Initialize GLFW, call CONTINUATION, and terminate GLFW on exit.
The callback is unregistered before its dynamic extent ends."
  (sb-alien:with-alien-callable
      ((error-callback sb-alien:void
                        ((code sb-alien:int) (description sb-alien:c-string))
         (setf *last-glfw-error* (cons code description))))
    (%glfw-set-error-callback (sb-alien:cast error-callback (* t)))
    (unwind-protect
         (progn
           (unless (= 1 (funcall *init-function*))
             (error 'glfw-platform-error :description "glfwInit failed"))
           (unwind-protect (funcall continuation)
             (funcall *terminate-function*)))
      (%glfw-set-error-callback (%null-pointer)))))

(defmacro with-glfw (() &body body)
  "Run BODY with GLFW initialized, terminating it on the way out -- success
or error. Thin syntax over CALL-WITH-GLFW."
  `(call-with-glfw (lambda () ,@body)))
