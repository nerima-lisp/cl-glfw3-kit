(in-package #:cl-glfw3-kit/test)

(describe
  "cl-glfw3-kit conditions"
  (it "CL-GLFW3-KIT-ERROR is a proper ERROR subtype"
    (expect (subtypep 'cl-glfw3-kit-error 'error) :to-be-truthy))

  (describe-each
      ((glfw-not-initialized) (glfw-invalid-enum) (glfw-invalid-value)
       (glfw-platform-error))
      "~A is a CL-GLFW3-KIT-ERROR that reports its description"
      (condition-type)
    (it "is a proper CL-GLFW3-KIT-ERROR subtype"
      ;; CONDITION-TYPE is a runtime value, so use EXPECT's dynamic throw check.
      (expect (subtypep condition-type 'cl-glfw3-kit-error) :to-be-truthy))
    (it "carries and reports the description it was signalled with"
      (handler-case (error condition-type :description "boom")
        (cl-glfw3-kit-error (c)
          (expect (search "boom" (princ-to-string c)) :to-be-truthy)))))

  (it "GLFW-UNKNOWN-ERROR carries both a code and a description"
    (handler-case (error 'glfw-unknown-error :code 999 :description "mystery")
      (glfw-unknown-error (c)
        (expect (glfw-unknown-error-code c) :to-equal 999)
        (expect (search "mystery" (princ-to-string c)) :to-be-truthy)))))

(describe
  "%check-glfw-error / *last-glfw-error*"
  (before-each (setf *last-glfw-error* nil))

  (it "does nothing when no error was recorded"
    (finishes (%check-glfw-error)))

  (describe-each
      ((#x00010001 glfw-not-initialized) (#x00010003 glfw-invalid-enum)
       (#x00010004 glfw-invalid-value) (#x00010008 glfw-platform-error))
      "maps GLFW error code ~A to ~A"
      (code condition-type)
    (it "signals the mapped condition and clears *LAST-GLFW-ERROR*"
      (setf *last-glfw-error* (cons code "from GLFW"))
      (expect (lambda () (%check-glfw-error)) :to-throw condition-type)
      (expect *last-glfw-error* :to-equal nil)))

  (it "signals GLFW-UNKNOWN-ERROR for a code absent from *GLFW-ERROR-CONDITIONS*"
    (setf *last-glfw-error* (cons -1 "not a real GLFW error code"))
    (signals glfw-unknown-error (%check-glfw-error))))
