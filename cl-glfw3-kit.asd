;;;; cl-glfw3-kit.asd
(in-package #:asdf-user)

(defsystem "cl-glfw3-kit"
  :description "Common Lisp bindings for GLFW3 window, input, and context management"
  :long-description "cl-glfw3-kit binds GLFW3, the cross-platform library for
creating windows, OpenGL/OpenGL-ES contexts, and handling keyboard, mouse,
and monitor input. The binding is SB-ALIEN, not cffi: SBCL's own FFI is
bundled with the implementation, so DEPENDENCY_POLICY.md's external-
dependency procedure never applies (see :depends-on below), and calling
GLFW's C functions directly needs no adapter layer. See
docs/src/project/roadmap.md for the API surface this binds and what is
deliberately out of scope, and docs/src/getting-started.md for
CL_GLFW3_KIT_LIBRARY, the environment variable that points this system at
the actual GLFW shared library (flake.nix wires it to nixpkgs' pkgs.glfw
automatically)."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.2.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
  ;; NO EXTERNAL DEPENDENCIES: the FFI layer is SB-ALIEN, part of SBCL
  ;; itself, not cffi. DEPENDENCY_POLICY.md treats SB-* as an implementation
  ;; dependency rather than an external one, so its four-condition procedure
  ;; for adding a new external dependency never applies here.
  :depends-on ()
  :pathname "src"
  :serial t
  :components
  ((:file "package")
   (:file "conditions")
   (:file "constants")
   (:file "core")
   (:file "library")
   (:file "init")
   (:file "window")
   (:file "callbacks")
   (:file "input")
   (:file "context")
   (:file "monitor"))
  :in-order-to ((test-op (test-op "cl-glfw3-kit/test"))))

(defsystem "cl-glfw3-kit/test"
  :description "Test system for cl-glfw3-kit"
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.2.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
  :depends-on ("cl-glfw3-kit"
               "cl-weave"        ; test framework, describe/it/expect/describe-each/gen-*
               "cl-boundary-kit") ; recording-boundary assertions over the window-creation test seam
  :pathname "t"
  :serial t
  :components
  ((:file "package")
   (:file "helpers-glfw")
   (:file "helpers-window")
   (:file "conditions-test")
   (:file "constants-test")
   (:file "core-test")
   (:file "library-test")
   (:file "init-test")
   (:file "window-test")
   (:file "callbacks-test")
   (:file "input-test")
   (:file "context-test")
   (:file "monitor-test"))
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (funcall (symbol-function (find-symbol "RUN-TESTS" "CL-GLFW3-KIT/TEST")))
               (error "cl-glfw3-kit test suite failed"))))

;; The real-hardware suite, split out of cl-glfw3-kit/test the way nerimux's
;; real-PTY suite is split into nerimux/pty-test: `nix flake check` builds in
;; a sandbox with no display server, so glfwInit() itself fails there on
;; Linux (GLFW needs a DISPLAY/X11 connection to select a platform backend).
;; Every case that touches a real GLFWwindow -- not the window-creation test
;; seam cl-glfw3-kit/test uses, an actual glfwCreateWindow call -- lives
;; here instead, so the main suite's green means "the marshalling logic is
;; correct" and this suite's green means "it also works against real GLFW,"
;; rather than one number blurring both.
;;
;; Run with: nix run .#test-hardware (or (asdf:test-system "cl-glfw3-kit/hardware-test")
;; on a machine with a real display, e.g. this org's aarch64-darwin dev machines).
(defsystem "cl-glfw3-kit/hardware-test"
  :description "Real-GLFWwindow suite for cl-glfw3-kit: every case that needs a real display."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.2.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
  :depends-on ("cl-glfw3-kit" "cl-weave")
  :pathname "t/hardware"
  :serial t
  :components
  ((:file "package")
   (:file "hardware-test"))
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (funcall (symbol-function
                                (find-symbol "RUN-HARDWARE-TESTS" "CL-GLFW3-KIT/HARDWARE-TEST")))
               (error "cl-glfw3-kit real-hardware test suite failed"))))
