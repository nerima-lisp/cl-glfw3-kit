(in-package #:cl-glfw3-kit/test)

(defun call-with-stubbed-glfw (continuation &key (init-result 1))
  "Run CONTINUATION with the GLFW init functions bound to a recording boundary."
  (let* ((boundary (make-recording-boundary
                     :handler (lambda (operation &rest args)
                                (declare (ignore args))
                                (when (eq operation :init) init-result))))
         (*init-function* (lambda () (recording-boundary-invoke boundary :init)))
         (*terminate-function* (lambda () (recording-boundary-invoke boundary :terminate))))
    (funcall continuation boundary)))
