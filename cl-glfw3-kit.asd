;;;; cl-glfw3-kit.asd
(in-package #:asdf-user)

(defsystem "cl-glfw3-kit"
  :description "Common Lisp CFFI bindings for GLFW3 window, input, and context management"
  :long-description "cl-glfw3-kit will provide Common Lisp bindings for
GLFW3, the cross-platform library for creating windows, OpenGL/Vulkan
contexts, and handling keyboard/mouse/joystick input. The actual CFFI
bindings are not implemented yet -- this repository is provisioning only.
See docs/src/project/roadmap.md, and DEPENDENCY_POLICY.md's 4-condition
external-dependency test in nerima-lisp/.github, which the PR that adds a
real cffi :depends-on must satisfy explicitly (cffi is only precedented for
cl-tmux today, an L4 repository)."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
  :depends-on ()
  :pathname "src"
  :serial t
  :components
  ((:file "package")
   (:file "conditions")
   (:file "core"))
  :in-order-to ((test-op (test-op "cl-glfw3-kit/test"))))

(defsystem "cl-glfw3-kit/test"
  :description "Test system for cl-glfw3-kit"
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :homepage "https://github.com/nerima-lisp/cl-glfw3-kit"
  :bug-tracker "https://github.com/nerima-lisp/cl-glfw3-kit/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-glfw3-kit.git")
  :depends-on ("cl-glfw3-kit" "cl-weave")
  :pathname "t"
  :serial t
  :components
  ((:file "package")
   (:file "core-test"))
  :perform (test-op (operation component)
             (declare (ignore operation component))
             (unless (funcall (symbol-function (find-symbol "RUN-TESTS" "CL-GLFW3-KIT/TEST")))
               (error "cl-glfw3-kit test suite failed"))))
