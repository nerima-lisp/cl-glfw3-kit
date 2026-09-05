(in-package #:cl-glfw3-kit/test)

(describe
  "SWAP-INTERVAL"
  ;; This operation does not require a window or context.
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
