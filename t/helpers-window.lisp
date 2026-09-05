(in-package #:cl-glfw3-kit/test)

(defvar *stub-window-pointer* (sb-alien:sap-alien (sb-sys:int-sap #x1) (* t))
  "A non-NULL alien pointer used by the window test double.")

(defun call-with-stubbed-window (continuation &key (create-result *stub-window-pointer*))
  "Run CONTINUATION with the window functions bound to a recording boundary."
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
