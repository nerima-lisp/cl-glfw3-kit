(in-package #:cl-glfw3-kit)

(define-glfw-function %glfw-get-key "glfwGetKey" sb-alien:int
  (window glfw-window-alien) (key sb-alien:int))
(define-glfw-function %glfw-get-mouse-button "glfwGetMouseButton" sb-alien:int
  (window glfw-window-alien) (button sb-alien:int))
(define-glfw-function %glfw-get-cursor-pos "glfwGetCursorPos" sb-alien:void
  (window glfw-window-alien) (x (* sb-alien:double)) (y (* sb-alien:double)))

(defun %key-code (key)
  "Translate a *GLFW-KEYS* keyword into its GLFW key code."
  (or (cdr (assoc key *glfw-keys*))
      (error 'glfw-invalid-enum :description (format nil "~S is not a known key" key))))

(defun %mouse-button-code (button)
  "Translate a *GLFW-MOUSE-BUTTONS* keyword into its GLFW button code."
  (or (cdr (assoc button *glfw-mouse-buttons*))
      (error 'glfw-invalid-enum
             :description (format nil "~S is not a known mouse button" button))))

(defun key-pressed-p (window key)
  "True while KEY (a *GLFW-KEYS* keyword, e.g. :SPACE, :A, :LEFT) is held
down or repeating on WINDOW."
  (/= (cdr (assoc :release *glfw-actions*))
      (%glfw-get-key (glfw-window-pointer window) (%key-code key))))

(defun mouse-button-pressed-p (window button)
  "True while BUTTON (a *GLFW-MOUSE-BUTTONS* keyword, e.g. :LEFT, :BUTTON-4)
is held down on WINDOW."
  (/= (cdr (assoc :release *glfw-actions*))
      (%glfw-get-mouse-button (glfw-window-pointer window) (%mouse-button-code button))))

(defun cursor-position (window)
  "Return (VALUES X Y), the cursor position relative to WINDOW's content area."
  (sb-alien:with-alien ((x sb-alien:double) (y sb-alien:double))
    (%glfw-get-cursor-pos (glfw-window-pointer window) (sb-alien:addr x) (sb-alien:addr y))
    (values x y)))
