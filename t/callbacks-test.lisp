;;;; t/callbacks-test.lisp
;;;;
;;;; CALL-WITH-GLFW-CALLBACKS installs real GLFW callback setters directly
;;;; on the window's own pointer -- unlike window creation/destruction,
;;;; there is no seam for it to go through (GLFW writes into the pointer's
;;;; own per-window callback table), so it is not exercised against
;;;; *STUB-WINDOW-POINTER* here; doing so would be undefined behaviour, not
;;;; a controlled test double. See t/hardware/hardware-test.lisp, where it
;;;; runs against a real window and fires real events. The pure decode
;;;; helpers %DECODE-MODS/%KEY-KEYWORD/%MOUSE-BUTTON-KEYWORD/%ACTION-KEYWORD
;;;; every callback dispatches through are already covered in
;;;; t/constants-test.lisp; only WITH-GLFW-CALLBACKS' own macro shape is
;;;; tested below.
(in-package #:cl-glfw3-kit/test)

(describe
  "WITH-GLFW-CALLBACKS"
  (it "expands to CALL-WITH-GLFW-CALLBACKS with a niladic lambda and the options forwarded"
    (let ((expansion (macroexpand-1 '(with-glfw-callbacks (my-window :on-key #'my-handler)
                                       (frame-body)))))
      (expect (first expansion) :to-equal 'call-with-glfw-callbacks)
      (expect (second expansion) :to-equal 'my-window)
      (destructuring-bind (lambda-form &rest options) (cddr expansion)
        (expect (first lambda-form) :to-equal 'lambda)
        (expect (second lambda-form) :to-equal nil)
        (expect options :to-equal (list :on-key '#'my-handler))))))
