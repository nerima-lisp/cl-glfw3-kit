;;;; src/context.lisp
(in-package #:cl-glfw3-kit)

(define-glfw-function %glfw-make-context-current "glfwMakeContextCurrent" sb-alien:void
  (window glfw-window-alien))
(define-glfw-function swap-interval "glfwSwapInterval" sb-alien:void
  (interval sb-alien:int))
(define-glfw-function %glfw-swap-buffers "glfwSwapBuffers" sb-alien:void
  (window glfw-window-alien))
(define-glfw-function poll-events "glfwPollEvents" sb-alien:void)
(define-glfw-function wait-events "glfwWaitEvents" sb-alien:void)
(define-glfw-function wait-events-timeout "glfwWaitEventsTimeout" sb-alien:void
  (timeout sb-alien:double))

(defun make-context-current (window)
  "Make WINDOW's OpenGL/OpenGL-ES context current on the calling thread."
  (%glfw-make-context-current (glfw-window-pointer window)))

(defun swap-buffers (window)
  "Swap the front and back buffers of WINDOW."
  (%glfw-swap-buffers (glfw-window-pointer window)))

(defun call-with-each-frame (window continuation &key (swap-buffers-p t))
  "Call CONTINUATION with WINDOW once per frame -- POLL-EVENTS, then
CONTINUATION, then (if SWAP-BUFFERS-P) SWAP-BUFFERS -- until WINDOW's close
flag is set (WINDOW-SHOULD-CLOSE-P), the idiomatic GLFW main-loop
condition. The continuation-passing core of FOR-EACH-FRAME."
  (loop until (window-should-close-p window)
        do (poll-events)
           (funcall continuation window)
           (when swap-buffers-p (swap-buffers window))))

(defmacro for-each-frame ((window-variable window &rest options) &body body)
  "Run BODY once per frame on WINDOW, bound to WINDOW-VARIABLE, until its
close flag is set. OPTIONS are CALL-WITH-EACH-FRAME's keyword arguments
(:SWAP-BUFFERS-P). Thin syntax over CALL-WITH-EACH-FRAME."
  `(call-with-each-frame ,window (lambda (,window-variable) ,@body) ,@options))
