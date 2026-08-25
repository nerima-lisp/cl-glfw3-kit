;;;; src/constants.lisp
;;;;
;;;; Pure data: every GLFW integer constant this library uses, transcribed
;;;; from GLFW/glfw3.h (GLFW 3.4, as shipped by nixpkgs' pkgs.glfw.dev,
;;;; verified against the actual header rather than the online docs). No
;;;; logic lives here -- library.lisp, window.lisp, input.lisp and
;;;; monitor.lisp read these tables but never hardcode a GLFW integer of
;;;; their own.
(in-package #:cl-glfw3-kit)

(defparameter *glfw-error-conditions*
  '((#x00010001 . glfw-not-initialized)
    (#x00010002 . glfw-no-current-context)
    (#x00010003 . glfw-invalid-enum)
    (#x00010004 . glfw-invalid-value)
    (#x00010005 . glfw-out-of-memory)
    (#x00010006 . glfw-api-unavailable)
    (#x00010007 . glfw-version-unavailable)
    (#x00010008 . glfw-platform-error)
    (#x00010009 . glfw-format-unavailable)
    (#x0001000a . glfw-no-window-context)
    (#x0001000b . glfw-cursor-unavailable)
    (#x0001000c . glfw-feature-unavailable)
    (#x0001000d . glfw-feature-unimplemented)
    (#x0001000e . glfw-platform-unavailable))
  "GLFW error code -> the condition type DEFINE-GLFW-ERROR-CONDITION defined
for it, keyed by the integer glfwGetError()/the error callback reports.")

(defparameter *glfw-boolean-window-hints*
  '((:resizable . #x00020003)
    (:visible . #x00020004)
    (:decorated . #x00020005)
    (:auto-iconify . #x00020006)
    (:floating . #x00020007)
    (:maximized . #x00020008)
    (:center-cursor . #x00020009)
    (:transparent-framebuffer . #x0002000a)
    (:focus-on-show . #x0002000c)
    (:scale-to-monitor . #x0002200c)
    (:scale-framebuffer . #x0002200d)
    (:stereo . #x0002100c)
    (:srgb-capable . #x0002100e)
    (:doublebuffer . #x00021010)
    (:opengl-forward-compat . #x00022006))
  "Keyword -> GLFW window-hint id, for hints whose value is GLFW_TRUE/GLFW_FALSE.")

(defparameter *glfw-integer-window-hints*
  '((:context-version-major . #x00022002)
    (:context-version-minor . #x00022003)
    (:samples . #x0002100d)
    (:refresh-rate . #x0002100f))
  "Keyword -> GLFW window-hint id, for hints whose value is a plain integer.")

(defparameter *glfw-client-api-values*
  '((:opengl . #x00030001)
    (:opengl-es . #x00030002)
    (:no-api . 0))
  "Keyword -> GLFW_*_API value, for the :CLIENT-API window hint.")

(defparameter *glfw-opengl-profile-values*
  '((:any . 0)
    (:core . #x00032001)
    (:compat . #x00032002))
  "Keyword -> GLFW_OPENGL_*_PROFILE value, for the :OPENGL-PROFILE window hint.")

(defparameter *glfw-enum-window-hints*
  (list (list* :client-api #x00022001 *glfw-client-api-values*)
        (list* :opengl-profile #x00022008 *glfw-opengl-profile-values*))
  "Keyword -> (GLFW window-hint id . value-keyword-table), for window hints
whose value is itself one of a fixed set of keywords rather than a boolean
or a plain integer.")

(defparameter *glfw-keys*
  '((:unknown . -1)
    (:space . 32) (:apostrophe . 39) (:comma . 44) (:minus . 45) (:period . 46)
    (:slash . 47)
    (:0 . 48) (:1 . 49) (:2 . 50) (:3 . 51) (:4 . 52) (:5 . 53) (:6 . 54) (:7 . 55)
    (:8 . 56) (:9 . 57)
    (:semicolon . 59) (:equal . 61)
    (:a . 65) (:b . 66) (:c . 67) (:d . 68) (:e . 69) (:f . 70) (:g . 71) (:h . 72)
    (:i . 73) (:j . 74) (:k . 75) (:l . 76) (:m . 77) (:n . 78) (:o . 79) (:p . 80)
    (:q . 81) (:r . 82) (:s . 83) (:t . 84) (:u . 85) (:v . 86) (:w . 87) (:x . 88)
    (:y . 89) (:z . 90)
    (:left-bracket . 91) (:backslash . 92) (:right-bracket . 93) (:grave-accent . 96)
    (:world-1 . 161) (:world-2 . 162)
    (:escape . 256) (:enter . 257) (:tab . 258) (:backspace . 259) (:insert . 260)
    (:delete . 261) (:right . 262) (:left . 263) (:down . 264) (:up . 265)
    (:page-up . 266) (:page-down . 267) (:home . 268) (:end . 269)
    (:caps-lock . 280) (:scroll-lock . 281) (:num-lock . 282) (:print-screen . 283)
    (:pause . 284)
    (:f1 . 290) (:f2 . 291) (:f3 . 292) (:f4 . 293) (:f5 . 294) (:f6 . 295)
    (:f7 . 296) (:f8 . 297) (:f9 . 298) (:f10 . 299) (:f11 . 300) (:f12 . 301)
    (:f13 . 302) (:f14 . 303) (:f15 . 304) (:f16 . 305) (:f17 . 306) (:f18 . 307)
    (:f19 . 308) (:f20 . 309) (:f21 . 310) (:f22 . 311) (:f23 . 312) (:f24 . 313)
    (:f25 . 314)
    (:kp-0 . 320) (:kp-1 . 321) (:kp-2 . 322) (:kp-3 . 323) (:kp-4 . 324)
    (:kp-5 . 325) (:kp-6 . 326) (:kp-7 . 327) (:kp-8 . 328) (:kp-9 . 329)
    (:kp-decimal . 330) (:kp-divide . 331) (:kp-multiply . 332) (:kp-subtract . 333)
    (:kp-add . 334) (:kp-enter . 335) (:kp-equal . 336)
    (:left-shift . 340) (:left-control . 341) (:left-alt . 342) (:left-super . 343)
    (:right-shift . 344) (:right-control . 345) (:right-alt . 346) (:right-super . 347)
    (:menu . 348))
  "Keyword -> GLFW key code (GLFW_KEY_* in glfw3.h), one entry per
GLFW_KEY_<NAME> with NAME lowercased to a keyword.")

(defparameter *glfw-mouse-buttons*
  '((:button-1 . 0) (:button-2 . 1) (:button-3 . 2) (:button-4 . 3)
    (:button-5 . 4) (:button-6 . 5) (:button-7 . 6) (:button-8 . 7)
    (:left . 0) (:right . 1) (:middle . 2))
  "Keyword -> GLFW mouse button code (GLFW_MOUSE_BUTTON_* in glfw3.h). :LEFT/
:RIGHT/:MIDDLE are the GLFW_MOUSE_BUTTON_LEFT/RIGHT/MIDDLE aliases, mapping
to the same integers as :BUTTON-1/:BUTTON-2/:BUTTON-3.")

(defparameter *glfw-actions*
  '((:release . 0) (:press . 1) (:repeat . 2))
  "Keyword -> GLFW_RELEASE/GLFW_PRESS/GLFW_REPEAT, the action GLFW reports
for a key or mouse button event.")

(defparameter *glfw-mod-keys*
  '((:shift . #x0001) (:control . #x0002) (:alt . #x0004) (:super . #x0008)
    (:caps-lock . #x0010) (:num-lock . #x0020))
  "Keyword -> GLFW_MOD_* bitmask value, decoded from a callback's MODS
argument into a list of the modifier keywords currently held.")
