;;;; t/helpers-window.lisp
;;;;
;;;; Shared fixture for exercising window-creation marshalling without a
;;;; real display: rebinds *CREATE-WINDOW-FUNCTION*/*DESTROY-WINDOW-FUNCTION*
;;;; to a CL-BOUNDARY-KIT recording boundary, so tests can assert on exactly
;;;; which calls CALL-WITH-GLFW-WINDOW made without ever touching GLFW.
(in-package #:cl-glfw3-kit/test)

(defvar *stub-window-pointer* (sb-alien:sap-alien (sb-sys:int-sap #x1) (* t))
  "A non-NULL alien pointer CALL-WITH-GLFW-WINDOW's NULL-check accepts, used
as the default fake GLFWwindow* the stubbed *CREATE-WINDOW-FUNCTION* below
returns.")

(defun call-with-stubbed-window (continuation &key (create-result *stub-window-pointer*))
  "Run CONTINUATION with *CREATE-WINDOW-FUNCTION*/*DESTROY-WINDOW-FUNCTION*
rebound to a CL-BOUNDARY-KIT recording boundary that never touches real
GLFW; CREATE-RESULT is what the stubbed creation call returns (a stub
pointer by default, or a null alien to exercise the failure path).
CONTINUATION receives the boundary, so a test can assert on
RECORDING-BOUNDARY-CALLS afterwards."
  (let* ((boundary (make-recording-boundary
                     :handler (lambda (operation &rest args)
                                (declare (ignore args))
                                (when (eq operation :create-window) create-result))))
         (*create-window-function*
           (lambda (width height title monitor share)
             (recording-boundary-invoke boundary :create-window width height title
                                         monitor share)))
         (*destroy-window-function*
           (lambda (pointer) (recording-boundary-invoke boundary :destroy-window pointer))))
    (funcall continuation boundary)))
