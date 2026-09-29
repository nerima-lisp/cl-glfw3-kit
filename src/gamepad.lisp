(in-package #:cl-glfw3-kit)

(defparameter *glfw-gamepad-buttons*
  '((:a . 0) (:b . 1) (:x . 2) (:y . 3) (:left-bumper . 4)
    (:right-bumper . 5) (:back . 6) (:start . 7) (:guide . 8)
    (:left-thumb . 9) (:right-thumb . 10) (:dpad-up . 11)
    (:dpad-right . 12) (:dpad-down . 13) (:dpad-left . 14))
  "Keyword -> GLFW gamepad button index.")

(defparameter *glfw-gamepad-axes*
  '((:left-x . 0) (:left-y . 1) (:right-x . 2) (:right-y . 3)
    (:left-trigger . 4) (:right-trigger . 5))
  "Keyword -> GLFW gamepad axis index.")

(sb-alien:define-alien-type gamepad-state-alien
    (sb-alien:struct nil
      (buttons (array sb-alien:unsigned-char 15))
      (axes (array sb-alien:float 6))))

(define-glfw-function %glfw-joystick-present "glfwJoystickPresent" sb-alien:int
  (joystick sb-alien:int))
(define-glfw-function %glfw-joystick-is-gamepad "glfwJoystickIsGamepad" sb-alien:int
  (joystick sb-alien:int))
(define-glfw-function %glfw-get-gamepad-state "glfwGetGamepadState" sb-alien:int
  (joystick sb-alien:int) (state (* gamepad-state-alien)))
(define-glfw-function %glfw-update-gamepad-mappings "glfwUpdateGamepadMappings" sb-alien:int
  (mappings sb-alien:c-string))

(defstruct (glfw-gamepad-state (:constructor %make-glfw-gamepad-state (buttons axes))
                               (:copier nil))
  "The fifteen digital buttons and six analogue axes reported by GLFW.
BUTTONS and AXES are simple vectors indexed by the corresponding gamepad
constant tables, or by integer index directly."
  buttons
  axes)

(defun joystick-present-p (joystick-id)
  "Return true when JOYSTICK-ID is connected.
JOYSTICK-ID is the integer GLFW joystick slot, normally 0 through 15."
  (= 1 (%glfw-joystick-present joystick-id)))

(defun joystick-gamepad-p (joystick-id)
  "Return true when JOYSTICK-ID has a GLFW gamepad mapping."
  (= 1 (%glfw-joystick-is-gamepad joystick-id)))

(defun gamepad-state (joystick-id)
  "Return JOYSTICK-ID's GLFW-GAMEPAD-STATE, or NIL when unavailable.
The returned BUTTONS vector contains GLFW_PRESS/GLFW_RELEASE integers and
the AXES vector contains single-float values in GLFW's [-1, 1] range."
  (sb-alien:with-alien ((state gamepad-state-alien))
    (when (= 1 (%glfw-get-gamepad-state joystick-id (sb-alien:addr state)))
      (let ((buttons (make-array 15))
            (axes (make-array 6)))
        (dotimes (index 15)
          (setf (aref buttons index)
                (sb-alien:deref (sb-alien:slot state 'buttons) index)))
        (dotimes (index 6)
          (setf (aref axes index)
                (sb-alien:deref (sb-alien:slot state 'axes) index)))
        (%make-glfw-gamepad-state buttons axes)))))

(defun update-gamepad-mappings (mappings)
  "Install GLFW_GAMEPAD_MAPPING database text and return true on success."
  (= 1 (%glfw-update-gamepad-mappings mappings)))
