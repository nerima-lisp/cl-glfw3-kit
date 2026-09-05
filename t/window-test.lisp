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
       ;; Alien wrappers for the same null pointer are not EQUAL.
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
