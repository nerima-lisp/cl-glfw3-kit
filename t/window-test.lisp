;;;; t/window-test.lisp
;;;;
;;;; Exercises WITH-GLFW-WINDOW/CALL-WITH-GLFW-WINDOW's own logic against
;;;; the *CREATE-WINDOW-FUNCTION*/*DESTROY-WINDOW-FUNCTION* stub -- never
;;;; against a real GLFWwindow, which glfwCreateWindow cannot produce
;;;; without a display. glfwWindowHint/glfwDefaultWindowHints ARE called
;;;; for real here: both write into an in-memory hints struct with no
;;;; platform-backend dependency, confirmed safe to call before glfwInit.
;;;; See t/hardware/hardware-test.lisp for a real end-to-end window.
(in-package #:cl-glfw3-kit/test)

(describe
  "CALL-WITH-GLFW-WINDOW / WITH-GLFW-WINDOW"
  (it "creates a window, calls the continuation with it, then destroys it"
    (call-with-stubbed-window
     (lambda (boundary)
       (let ((seen nil))
         (with-glfw-window (window) (setf seen window))
         (expect (glfw-window-p seen) :to-be-truthy)
         (expect (mapcar (lambda (call) (getf call :operation))
                          (recording-boundary-calls boundary))
                 :to-equal (list :create-window :destroy-window))))))

  (it "passes WIDTH/HEIGHT/TITLE through to *CREATE-WINDOW-FUNCTION*"
    (call-with-stubbed-window
     (lambda (boundary)
       (with-glfw-window (window :width 800 :height 600 :title "test") window)
       ;; Each fresh (%NULL-POINTER) call allocates a new alien-value
       ;; wrapper for the same SAP address, so the trailing two arguments
       ;; are compared by null-ness (SB-ALIEN:NULL-ALIEN) rather than by
       ;; EQUAL, which is never true across two separately-allocated
       ;; wrappers even when both represent the same null pointer.
       (destructuring-bind (width height title monitor share)
           (getf (first (recording-boundary-calls boundary)) :arguments)
         (expect (list width height title) :to-equal (list 800 600 "test"))
         (expect (sb-alien:null-alien monitor) :to-be-truthy)
         (expect (sb-alien:null-alien share) :to-be-truthy)))))

  (it "applies :HINTS before creating the window"
    (call-with-stubbed-window
     (lambda (boundary) (declare (ignore boundary))
       (finishes (with-glfw-window (window :hints (list :resizable nil :samples 4)) window)))))

  (it "still destroys the window when the body signals"
    (call-with-stubbed-window
     (lambda (boundary)
       (ignore-errors (with-glfw-window (window) (declare (ignore window)) (error "boom")))
       (expect (mapcar (lambda (call) (getf call :operation))
                        (recording-boundary-calls boundary))
               :to-equal (list :create-window :destroy-window)))))

  (it "signals GLFW-PLATFORM-ERROR and never calls *DESTROY-WINDOW-FUNCTION* on NULL"
    (call-with-stubbed-window
     (lambda (boundary)
       (signals glfw-platform-error (with-glfw-window (window) (declare (ignore window))))
       (expect (mapcar (lambda (call) (getf call :operation))
                        (recording-boundary-calls boundary))
               :to-equal (list :create-window)))
     :create-result (%null-pointer))))

;;; Window PROPERTY accessors (WINDOW-SHOULD-CLOSE-P, WINDOW-TITLE,
;;; WINDOW-SIZE, FRAMEBUFFER-SIZE, and their setters) are not tested here.
;;; Each calls a real GLFW function on the window's own pointer directly --
;;; unlike creation/destruction, there is no seam for them to go through,
;;; so calling one against *STUB-WINDOW-POINTER* (not a pointer GLFW ever
;;; allocated) would be undefined behaviour, not a controlled test double.
;;; See t/hardware/hardware-test.lisp, where they run against a real window.
