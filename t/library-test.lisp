(in-package #:cl-glfw3-kit/test)

(describe
  "DEFINE-GLFW-FUNCTION"
  (it "expands to a raw alien routine bound under %RAW-<NAME>, plus a public wrapper defun"
    (let ((expansion (macroexpand-1
                       '(define-glfw-function glfw3-kit-test-fn "cGlfw3KitTestFn" sb-alien:int
                         (x sb-alien:int)))))
      (expect (first expansion) :to-equal 'progn)
      (destructuring-bind (routine-form wrapper-form) (rest expansion)
        (expect (first routine-form) :to-equal 'sb-alien:define-alien-routine)
        (expect (first (second routine-form)) :to-equal "cGlfw3KitTestFn")
        (expect (symbol-name (second (second routine-form))) :to-equal "%RAW-GLFW3-KIT-TEST-FN")
        (expect (first wrapper-form) :to-equal 'defun)
        (expect (second wrapper-form) :to-equal 'glfw3-kit-test-fn)
        (expect (third wrapper-form) :to-equal '(x))))))

(describe
  "%SIGNAL-GLFW-ERROR"
  (it "signals the mapped condition for a known GLFW error code"
    (signals glfw-out-of-memory (%signal-glfw-error #x00010005 "no memory")))
  (it "signals GLFW-UNKNOWN-ERROR for an unmapped code"
    (signals glfw-unknown-error (%signal-glfw-error -12345 "future GLFW version"))))
