;;;; t/hardware/package.lisp
(defpackage #:cl-glfw3-kit/hardware-test
  (:use #:cl)
  (:shadowing-import-from #:cl-weave #:describe)
  (:import-from #:cl-weave #:it #:expect #:expect-not #:signals #:run-all)
  (:import-from #:cl-glfw3-kit
                #:with-glfw #:glfw-version #:glfw-version-string
                #:with-glfw-window #:with-glfw-callbacks
                #:window-should-close-p #:set-window-should-close
                #:window-size #:framebuffer-size #:window-title #:set-window-title
                #:make-context-current #:swap-interval #:swap-buffers
                #:for-each-frame
                #:key-pressed-p #:mouse-button-pressed-p #:cursor-position
                #:primary-monitor #:list-monitors #:video-mode
                #:video-mode-width #:video-mode-height #:video-mode-refresh-rate)
  (:export #:run-hardware-tests))

(in-package #:cl-glfw3-kit/hardware-test)

(defun run-hardware-tests (&key (reporter :spec))
  (unless (run-all :reporter reporter :timeout-ms 20000)
    (error "cl-glfw3-kit real-hardware test suite failed"))
  (format t "~&cl-glfw3-kit/hardware-test: successful completion with 0 failures~%")
  t)
