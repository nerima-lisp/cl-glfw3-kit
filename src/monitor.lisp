(in-package #:cl-glfw3-kit)

(defstruct (glfw-monitor (:constructor %make-glfw-monitor (pointer)) (:copier nil))
  "Opaque handle wrapping a GLFWmonitor* alien pointer."
  pointer)

(defstruct (video-mode (:constructor %make-video-mode
                            (width height red-bits green-bits blue-bits refresh-rate))
                        (:copier nil))
  "A monitor's resolution, per-channel bit depth, and refresh rate, as
reported by glfwGetVideoMode. See VIDEO-MODE, the accessor function."
  width height red-bits green-bits blue-bits refresh-rate)

(sb-alien:define-alien-type video-mode-alien
    (sb-alien:struct nil
      (width sb-alien:int) (height sb-alien:int)
      (red-bits sb-alien:int) (green-bits sb-alien:int) (blue-bits sb-alien:int)
      (refresh-rate sb-alien:int)))

(define-glfw-function %glfw-get-primary-monitor "glfwGetPrimaryMonitor" glfw-monitor-alien)
(define-glfw-function %glfw-get-monitors "glfwGetMonitors" (* glfw-monitor-alien)
  (count (* sb-alien:int)))
(define-glfw-function %glfw-get-video-mode "glfwGetVideoMode" (* video-mode-alien)
  (monitor glfw-monitor-alien))

(defun primary-monitor ()
  "Return the GLFW-MONITOR GLFW currently considers primary."
  (%make-glfw-monitor (%glfw-get-primary-monitor)))

(defun list-monitors ()
  "Return every currently connected monitor, as a list of GLFW-MONITOR."
  (sb-alien:with-alien ((count sb-alien:int))
    (let ((monitors (%glfw-get-monitors (sb-alien:addr count))))
      (loop for i below count
            collect (%make-glfw-monitor (sb-alien:deref monitors i))))))

(defun video-mode (monitor)
  "Return MONITOR's current VIDEO-MODE."
  (let ((mode (%glfw-get-video-mode (glfw-monitor-pointer monitor))))
    (%make-video-mode (sb-alien:slot mode 'width) (sb-alien:slot mode 'height)
                       (sb-alien:slot mode 'red-bits) (sb-alien:slot mode 'green-bits)
                       (sb-alien:slot mode 'blue-bits) (sb-alien:slot mode 'refresh-rate))))
