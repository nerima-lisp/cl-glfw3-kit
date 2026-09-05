(in-package #:cl-glfw3-kit/test)

(describe
  "WITH-GLFW-CALLBACKS"
  (it "expands to CALL-WITH-GLFW-CALLBACKS with a niladic lambda and the options forwarded"
    (let ((expansion (macroexpand-1 '(with-glfw-callbacks (my-window :on-key #'my-handler)
                                       (frame-body)))))
      (expect (first expansion) :to-equal 'call-with-glfw-callbacks)
      (expect (second expansion) :to-equal 'my-window)
      (destructuring-bind (lambda-form &rest options) (cddr expansion)
        (expect (first lambda-form) :to-equal 'lambda)
        (expect (second lambda-form) :to-equal nil)
        (expect options :to-equal (list :on-key '#'my-handler))))))
