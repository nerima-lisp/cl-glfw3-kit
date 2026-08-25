;;;; src/init.lisp
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
  "The function CALL-WITH-GLFW calls to initialize GLFW, as (FUNCALL
*INIT-FUNCTION*) -- rebindable, together with *TERMINATE-FUNCTION*, so
tests can exercise CALL-WITH-GLFW's error-callback and teardown logic
without a real display. GLFW needs one to initialize at all (glfwInit
itself fails without a DISPLAY/X11 connection on headless Linux -- exactly
the CI sandbox `nix flake check` runs in), unlike window creation, which
merely needs GLFW already initialized. Defaults to %GLFW-INIT, the real
GLFW call.")

(defvar *terminate-function* #'%glfw-terminate
  "The function CALL-WITH-GLFW calls to shut GLFW down, as (FUNCALL
*TERMINATE-FUNCTION*). See *INIT-FUNCTION* -- the two are rebound together.
Defaults to %GLFW-TERMINATE, the real GLFW call.")

(defun call-with-glfw (continuation)
  "Install the error callback, call *INIT-FUNCTION*, call CONTINUATION with
no arguments, then call *TERMINATE-FUNCTION* on the way out -- success or
error. The continuation-passing core of WITH-GLFW. The error callback is a
dynamic-extent closure via WITH-ALIEN-CALLABLE, valid only while
CONTINUATION runs -- and is explicitly unregistered from GLFW
(glfwSetErrorCallback NULL) before that dynamic extent ends, in the
innermost UNWIND-PROTECT below: WITH-ALIEN-CALLABLE tears down the Lisp-side
trampoline on scope exit regardless, but GLFW itself keeps whatever raw
pointer glfwSetErrorCallback last registered, in global, process-wide state
that outlives this call. Leaving that registration in place after the
trampoline it points to is gone means the next error ANY later GLFW call
reports -- in a completely unrelated part of the program -- calls through
a dead pointer instead of doing nothing."
  (sb-alien:with-alien-callable
      ((error-callback sb-alien:void
                        ((code sb-alien:int) (description sb-alien:c-string))
         (setf *last-glfw-error* (cons code description))))
    (%glfw-set-error-callback (sb-alien:cast error-callback (* t)))
    (unwind-protect
         (progn
           (unless (= 1 (funcall *init-function*))
             ;; %CHECK-GLFW-ERROR (run inside %GLFW-INIT itself, when
             ;; *INIT-FUNCTION* is the real one) already signals the specific
             ;; condition whenever the error callback fired, which GLFW's
             ;; documented contract says it does on every glfwInit failure --
             ;; this is a defensive fallback for the undocumented case where
             ;; it did not, not the expected path.
             (error 'glfw-platform-error :description "glfwInit failed"))
           (unwind-protect (funcall continuation)
             (funcall *terminate-function*)))
      (%glfw-set-error-callback (%null-pointer)))))

(defmacro with-glfw (() &body body)
  "Run BODY with GLFW initialized, terminating it on the way out -- success
or error. Thin syntax over CALL-WITH-GLFW."
  `(call-with-glfw (lambda () ,@body)))
