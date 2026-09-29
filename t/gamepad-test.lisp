(in-package #:cl-glfw3-kit/test)

(describe
  "GAMEPAD CONSTANTS"
  (it "contains all fifteen GLFW gamepad buttons"
    (expect (length *glfw-gamepad-buttons*) :to-equal 15)
    (expect (cdr (assoc :a *glfw-gamepad-buttons*)) :to-equal 0)
    (expect (cdr (assoc :dpad-left *glfw-gamepad-buttons*)) :to-equal 14))

  (it "contains all six GLFW gamepad axes"
    (expect (length *glfw-gamepad-axes*) :to-equal 6)
    (expect (cdr (assoc :left-x *glfw-gamepad-axes*)) :to-equal 0)
    (expect (cdr (assoc :right-trigger *glfw-gamepad-axes*)) :to-equal 5)))

(describe
  "KEY CONSTANTS"
  (it "exposes the keyboard codes needed for a typical NES binding"
    (expect (key-code :z) :to-equal 90)
    (expect (key-code :x) :to-equal 88)
    (expect (key-code :enter) :to-equal 257)
    (expect (key-code :right) :to-equal 262)))
