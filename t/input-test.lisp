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
