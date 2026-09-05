(in-package #:cl-glfw3-kit/test)

(describe
  "PRIMARY-MONITOR / LIST-MONITORS"
  (it "PRIMARY-MONITOR returns a GLFW-MONITOR"
    (expect (glfw-monitor-p (primary-monitor)) :to-be-truthy))

  (it "LIST-MONITORS returns a list of GLFW-MONITOR"
    (expect (every #'glfw-monitor-p (list-monitors)) :to-be-truthy)))
