;;;; t/context-test.lisp
;;;;
;;;; MAKE-CONTEXT-CURRENT/SWAP-BUFFERS take a window pointer directly,
;;;; POLL-EVENTS/WAIT-EVENTS/WAIT-EVENTS-TIMEOUT need the platform backend
;;;; running, and CALL-WITH-EACH-FRAME/FOR-EACH-FRAME call both a window
;;;; pointer function (WINDOW-SHOULD-CLOSE-P) and POLL-EVENTS -- none of
;;;; them go through a seam, so none are exercised here for the same
;;;; reason as t/window-test.lisp's property-accessor note. See
;;;; t/hardware/hardware-test.lisp for the real end-to-end path.
(in-package #:cl-glfw3-kit/test)

(describe
  "SWAP-INTERVAL"
  ;; No window/context argument at all, and (like glfwWindowHint) writes
  ;; into global state with no platform-backend dependency -- confirmed
  ;; safe to call before glfwInit, unlike every other context.lisp function.
  (it "does not signal when called with no current context"
    (finishes (swap-interval 1))))

(describe
  "FOR-EACH-FRAME"
  (it "expands to CALL-WITH-EACH-FRAME with a unary lambda and the options forwarded"
    (let ((expansion (macroexpand-1 '(for-each-frame (win my-window :swap-buffers-p nil)
                                       (frame-body)))))
      (expect (first expansion) :to-equal 'call-with-each-frame)
      (expect (second expansion) :to-equal 'my-window)
      (destructuring-bind (lambda-form &rest options) (cddr expansion)
        (expect (first lambda-form) :to-equal 'lambda)
        (expect (second lambda-form) :to-equal '(win))
        (expect options :to-equal (list :swap-buffers-p nil))))))
