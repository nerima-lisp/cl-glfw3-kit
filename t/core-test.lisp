(in-package #:cl-glfw3-kit/test)

(describe
  "cl-glfw3-kit"
  (it "reports its own version, matching the .asd :version"
    (expect (library-version) :to-equal "0.2.0"))

  (it "CL-GLFW3-KIT-ERROR is a proper ERROR subtype"
    (expect (subtypep 'cl-glfw3-kit-error 'error) :to-be-truthy)))
