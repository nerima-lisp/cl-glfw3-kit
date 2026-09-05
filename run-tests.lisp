(require :asdf)
(format t "tests: bootstrap~%")

(defun script-directory ()
  (make-pathname :name nil
                 :type nil
                 :defaults (or *load-truename*
                               *compile-file-truename*
                               (error "Unable to determine the script location"))))

(let ((root (script-directory)))
  (format t "tests: system definition~%")
  (push root asdf:*central-registry*)
  (push (merge-pathnames #P"../cl-weave/" root) asdf:*central-registry*)
  (push (merge-pathnames #P"../cl-boundary-kit/" root) asdf:*central-registry*)
  (push (merge-pathnames #P"../cl-host-kit/" root) asdf:*central-registry*)
  (format t "tests: run~%")
  (asdf:test-system "cl-glfw3-kit")
  (format t "tests: complete~%")
  (uiop:quit 0))
