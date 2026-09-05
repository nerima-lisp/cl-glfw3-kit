(in-package #:asdf-user)

(defsystem "cl-glfw3-kit"
  :description "Common Lisp bindings for GLFW3 window, input, and context management"
  :long-description "cl-glfw3-kit provides SB-ALIEN bindings for GLFW3. See
docs/src/getting-started.md for the library path configuration."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.2.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
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

;; Real GLFW tests are separate because the flake-check sandbox has no display
;; server. Run with nix run .#test-hardware on a machine with a display.
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
