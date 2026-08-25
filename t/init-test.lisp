;;;; t/init-test.lisp
;;;;
;;;; Exercises CALL-WITH-GLFW/WITH-GLFW's own logic (error-callback install,
;;;; success path, teardown-on-error, the defensive init-failure fallback)
;;;; against the *INIT-FUNCTION*/*TERMINATE-FUNCTION* stub -- never against
;;;; real GLFW, which glfwInit() cannot reach without a display. See
;;;; t/hardware/hardware-test.lisp for the real end-to-end path.
(in-package #:cl-glfw3-kit/test)

(describe
  "CALL-WITH-GLFW / WITH-GLFW"
  (it "calls *INIT-FUNCTION*, the continuation, then *TERMINATE-FUNCTION*, in order"
    (call-with-stubbed-glfw
     (lambda (boundary)
       (let ((ran nil))
         (with-glfw () (setf ran t))
         (expect ran :to-be-truthy)
         (expect (mapcar (lambda (call) (getf call :operation)) (recording-boundary-calls boundary))
                 :to-equal (list :init :terminate))))))

  (it "still calls *TERMINATE-FUNCTION* when the body signals"
    (call-with-stubbed-glfw
     (lambda (boundary)
       (ignore-errors (with-glfw () (error "boom")))
       (expect (mapcar (lambda (call) (getf call :operation)) (recording-boundary-calls boundary))
               :to-equal (list :init :terminate)))))

  (it "returns the continuation's value"
    (call-with-stubbed-glfw
     (lambda (boundary) (declare (ignore boundary))
       (expect (with-glfw () 42) :to-equal 42))))

  (it "signals GLFW-PLATFORM-ERROR and never calls *TERMINATE-FUNCTION* when init fails"
    (call-with-stubbed-glfw
     (lambda (boundary)
       (signals glfw-platform-error (with-glfw () (error "unreachable")))
       (expect (mapcar (lambda (call) (getf call :operation)) (recording-boundary-calls boundary))
               :to-equal (list :init)))
     :init-result 0)))

(describe
  "GLFW-VERSION / GLFW-VERSION-STRING"
  ;; Both call the real GLFW library directly (no *INIT-FUNCTION*-style
  ;; seam): glfwGetVersion/glfwGetVersionString are documented safe to call
  ;; before glfwInit and read no display/platform state, unlike glfwInit
  ;; itself -- exercised for real here rather than stubbed.
  (it "GLFW-VERSION returns three non-negative integers"
    (multiple-value-bind (major minor revision) (glfw-version)
      (expect (>= major 3) :to-be-truthy)
      (expect (>= minor 0) :to-be-truthy)
      (expect (>= revision 0) :to-be-truthy)))
  (it "GLFW-VERSION-STRING contains the same major.minor as GLFW-VERSION"
    (multiple-value-bind (major minor) (glfw-version)
      (expect (search (format nil "~D.~D" major minor) (glfw-version-string)) :to-be-truthy))))
