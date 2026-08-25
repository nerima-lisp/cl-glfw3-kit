;;;; t/monitor-test.lisp
;;;;
;;;; PRIMARY-MONITOR/LIST-MONITORS call real GLFW functions with no window
;;;; or monitor pointer argument at all -- confirmed safe to call before
;;;; glfwInit (GLFW reports zero connected monitors rather than crashing).
;;;; VIDEO-MODE takes a monitor pointer directly and dereferences it, so it
;;;; is not exercised here: PRIMARY-MONITOR wraps a NULL pointer without a
;;;; real platform backend, and calling VIDEO-MODE on it would be undefined
;;;; behaviour. See t/hardware/hardware-test.lisp for the real end-to-end
;;;; path, including VIDEO-MODE against a monitor GLFW actually reports.
(in-package #:cl-glfw3-kit/test)

(describe
  "PRIMARY-MONITOR / LIST-MONITORS"
  (it "PRIMARY-MONITOR returns a GLFW-MONITOR"
    (expect (glfw-monitor-p (primary-monitor)) :to-be-truthy))

  (it "LIST-MONITORS returns a list of GLFW-MONITOR"
    (expect (every #'glfw-monitor-p (list-monitors)) :to-be-truthy)))
