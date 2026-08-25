;;;; t/helpers-glfw.lisp
;;;;
;;;; Shared fixture for exercising CALL-WITH-GLFW's error-callback and
;;;; teardown logic without a real display: rebinds
;;;; *INIT-FUNCTION*/*TERMINATE-FUNCTION* to a CL-BOUNDARY-KIT recording
;;;; boundary. glfwInit() itself fails without a DISPLAY/X11 connection on
;;;; headless Linux, exactly the sandbox `nix flake check` builds in, so
;;;; this suite never calls the real GLFW init/terminate pair -- see
;;;; t/hardware/hardware-test.lisp for that.
(in-package #:cl-glfw3-kit/test)

(defun call-with-stubbed-glfw (continuation &key (init-result 1))
  "Run CONTINUATION with *INIT-FUNCTION*/*TERMINATE-FUNCTION* rebound to a
CL-BOUNDARY-KIT recording boundary that never touches real GLFW;
INIT-RESULT is what the stubbed init call returns (1/GLFW_TRUE by default,
or 0/GLFW_FALSE to exercise CALL-WITH-GLFW's defensive failure path).
CONTINUATION receives the boundary, so a test can assert on
RECORDING-BOUNDARY-CALLS afterwards."
  (let* ((boundary (make-recording-boundary
                     :handler (lambda (operation &rest args)
                                (declare (ignore args))
                                (when (eq operation :init) init-result))))
         (*init-function* (lambda () (recording-boundary-invoke boundary :init)))
         (*terminate-function* (lambda () (recording-boundary-invoke boundary :terminate))))
    (funcall continuation boundary)))
