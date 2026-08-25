;;;; src/window.lisp
(in-package #:cl-glfw3-kit)

(defstruct (glfw-window (:constructor %make-glfw-window (pointer)) (:copier nil))
  "Opaque handle wrapping a GLFWwindow* alien pointer. Obtained only from
WITH-GLFW-WINDOW/CALL-WITH-GLFW-WINDOW, never constructed directly."
  pointer)

(define-glfw-function %glfw-default-window-hints "glfwDefaultWindowHints" sb-alien:void)
(define-glfw-function %glfw-window-hint "glfwWindowHint" sb-alien:void
  (hint sb-alien:int) (value sb-alien:int))
(define-glfw-function %glfw-create-window "glfwCreateWindow" glfw-window-alien
  (width sb-alien:int) (height sb-alien:int) (title sb-alien:c-string)
  (monitor glfw-monitor-alien) (share glfw-window-alien))
(define-glfw-function %glfw-destroy-window "glfwDestroyWindow" sb-alien:void
  (window glfw-window-alien))
(define-glfw-function %glfw-window-should-close "glfwWindowShouldClose" sb-alien:int
  (window glfw-window-alien))
(define-glfw-function %glfw-set-window-should-close "glfwSetWindowShouldClose" sb-alien:void
  (window glfw-window-alien) (value sb-alien:int))
(define-glfw-function %glfw-get-window-size "glfwGetWindowSize" sb-alien:void
  (window glfw-window-alien) (width (* sb-alien:int)) (height (* sb-alien:int)))
(define-glfw-function %glfw-get-framebuffer-size "glfwGetFramebufferSize" sb-alien:void
  (window glfw-window-alien) (width (* sb-alien:int)) (height (* sb-alien:int)))
(define-glfw-function %glfw-get-window-title "glfwGetWindowTitle" sb-alien:c-string
  (window glfw-window-alien))
(define-glfw-function %glfw-set-window-title "glfwSetWindowTitle" sb-alien:void
  (window glfw-window-alien) (title sb-alien:c-string))

(defun default-window-hints ()
  "Reset all window hints to their GLFW defaults."
  (%glfw-default-window-hints))

(defun %encode-window-hint-value (keyword value)
  "Translate one CREATE-WINDOW :HINTS entry (a KEYWORD/VALUE pair) into
(HINT-ID . INTEGER-VALUE), consulting *GLFW-BOOLEAN-WINDOW-HINTS*,
*GLFW-INTEGER-WINDOW-HINTS* and *GLFW-ENUM-WINDOW-HINTS*. Pure data
translation: no FFI call, so tests exercise every hint keyword without
touching GLFW at all."
  (let ((boolean-hint (assoc keyword *glfw-boolean-window-hints*))
        (integer-hint (assoc keyword *glfw-integer-window-hints*))
        (enum-hint (assoc keyword *glfw-enum-window-hints*)))
    (cond
      (boolean-hint (cons (cdr boolean-hint) (if value 1 0)))
      (integer-hint (cons (cdr integer-hint) value))
      (enum-hint
       (destructuring-bind (hint-id . value-table) (cdr enum-hint)
         (let ((entry (assoc value value-table)))
           (unless entry
             (error 'glfw-invalid-enum
                    :description (format nil "~S is not a valid value for window hint ~S"
                                          value keyword)))
           (cons hint-id (cdr entry)))))
      (t (error 'glfw-invalid-enum
                :description (format nil "~S is not a known window hint" keyword))))))

(defun %encode-window-hints (hints)
  "Translate the :HINTS plist CREATE-WINDOW/WITH-GLFW-WINDOW accepts into a
list of (HINT-ID . INTEGER-VALUE) pairs, ready for %APPLY-WINDOW-HINTS."
  (loop for (keyword value) on hints by #'cddr
        collect (%encode-window-hint-value keyword value)))

(defun %apply-window-hints (encoded-hints)
  "Call glfwWindowHint once per (HINT-ID . VALUE) pair ENCODED-HINTS holds."
  (dolist (pair encoded-hints)
    (%glfw-window-hint (car pair) (cdr pair))))

(defvar *create-window-function* #'%glfw-create-window
  "The function CALL-WITH-GLFW-WINDOW calls to create the underlying
GLFWwindow*, as (FUNCALL *CREATE-WINDOW-FUNCTION* WIDTH HEIGHT TITLE MONITOR
SHARE). Rebindable, together with *DESTROY-WINDOW-FUNCTION*, so tests can
exercise window-creation argument marshalling and error handling without a
real display -- see t/helpers-window.lisp. The two are rebound as a pair:
a stubbed pointer from this function must never reach the real
glfwDestroyWindow, which is undefined behaviour on a pointer GLFW never
allocated. Defaults to %GLFW-CREATE-WINDOW, the real GLFW call.")

(defvar *destroy-window-function* #'%glfw-destroy-window
  "The function CALL-WITH-GLFW-WINDOW calls to destroy the window
*CREATE-WINDOW-FUNCTION* created, as (FUNCALL *DESTROY-WINDOW-FUNCTION*
POINTER). See *CREATE-WINDOW-FUNCTION* -- the two are rebound together.
Defaults to %GLFW-DESTROY-WINDOW, the real GLFW call.")

(defun call-with-glfw-window (continuation &key (width 640) (height 480)
                                                 (title "") hints)
  "Apply HINTS (a plist, see %ENCODE-WINDOW-HINT-VALUE for accepted keys),
create a WIDTHxHEIGHT window titled TITLE, call CONTINUATION with the
resulting GLFW-WINDOW, then destroy it on the way out -- success or error.
The continuation-passing core of WITH-GLFW-WINDOW."
  (%apply-window-hints (%encode-window-hints hints))
  (let ((pointer (funcall *create-window-function* width height title
                           (%null-pointer) (%null-pointer))))
    (when (sb-alien:null-alien pointer)
      (error 'glfw-platform-error :description "glfwCreateWindow returned NULL"))
    (let ((window (%make-glfw-window pointer)))
      (unwind-protect (funcall continuation window)
        (funcall *destroy-window-function* pointer)))))

(defmacro with-glfw-window ((window-variable &rest options) &body body)
  "Bind WINDOW-VARIABLE to a newly created window for BODY, destroying it on
the way out -- success or error. OPTIONS are CALL-WITH-GLFW-WINDOW's
keyword arguments (:WIDTH, :HEIGHT, :TITLE, :HINTS). Thin syntax over
CALL-WITH-GLFW-WINDOW."
  `(call-with-glfw-window (lambda (,window-variable) ,@body) ,@options))

(defun window-should-close-p (window)
  (= 1 (%glfw-window-should-close (glfw-window-pointer window))))

(defun set-window-should-close (window value)
  (%glfw-set-window-should-close (glfw-window-pointer window) (if value 1 0)))

(defun window-size (window)
  "Return (VALUES WIDTH HEIGHT), WINDOW's size in screen coordinates."
  (sb-alien:with-alien ((width sb-alien:int) (height sb-alien:int))
    (%glfw-get-window-size (glfw-window-pointer window) (sb-alien:addr width)
                            (sb-alien:addr height))
    (values width height)))

(defun framebuffer-size (window)
  "Return (VALUES WIDTH HEIGHT), WINDOW's framebuffer size in pixels."
  (sb-alien:with-alien ((width sb-alien:int) (height sb-alien:int))
    (%glfw-get-framebuffer-size (glfw-window-pointer window) (sb-alien:addr width)
                                 (sb-alien:addr height))
    (values width height)))

(defun window-title (window)
  (%glfw-get-window-title (glfw-window-pointer window)))

(defun set-window-title (window title)
  (%glfw-set-window-title (glfw-window-pointer window) title))
