;;;; t/input-test.lisp
;;;;
;;;; KEY-PRESSED-P/MOUSE-BUTTON-PRESSED-P/CURSOR-POSITION each call a real
;;;; GLFW query function on the window's own pointer directly, with no seam
;;;; to go through -- not exercised against *STUB-WINDOW-POINTER* here for
;;;; the same reason as t/callbacks-test.lisp. See
;;;; t/hardware/hardware-test.lisp for the real end-to-end path. The pure
;;;; keyword<->code translation %KEY-CODE/%MOUSE-BUTTON-CODE they marshal
;;;; arguments through is tested below without touching GLFW at all.
(in-package #:cl-glfw3-kit/test)

(describe
  "%KEY-CODE / %MOUSE-BUTTON-CODE"
  (it-property "every known key keyword translates to its GLFW code"
      ((entry (gen-member *glfw-keys*)))
    (expect (%key-code (car entry)) :to-equal (cdr entry)))

  (it "signals GLFW-INVALID-ENUM for an unknown key keyword"
    (signals glfw-invalid-enum (%key-code :not-a-real-key)))

  (it-property "every known mouse-button keyword translates to its GLFW code"
      ((entry (gen-member *glfw-mouse-buttons*)))
    (expect (%mouse-button-code (car entry)) :to-equal (cdr entry)))

  (it "signals GLFW-INVALID-ENUM for an unknown mouse-button keyword"
    (signals glfw-invalid-enum (%mouse-button-code :not-a-real-button))))
