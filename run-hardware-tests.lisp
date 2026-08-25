;;;; run-hardware-tests.lisp
;;;;
;;;; Bootstrap script: registers this checkout's and cl-weave's ASDF
;;;; definitions and runs cl-glfw3-kit/hardware-test, the real-GLFWwindow
;;;; suite -- needs a real display, so run only by hand (`nix run
;;;; .#test-hardware`), never as part of `nix flake check`.

(require :asdf)
(format t "hardware-tests: bootstrap~%")

(defun script-directory ()
  (make-pathname :name nil
                 :type nil
                 :defaults (or *load-truename*
                               *compile-file-truename*
                               (error "Unable to determine the script location"))))

(let ((root (script-directory)))
  (format t "hardware-tests: system definition~%")
  (push root asdf:*central-registry*)
  (push (merge-pathnames #P"../cl-weave/" root) asdf:*central-registry*)
  (format t "hardware-tests: run~%")
  (asdf:test-system "cl-glfw3-kit/hardware-test")
  (format t "hardware-tests: complete~%")
  (uiop:quit 0))
