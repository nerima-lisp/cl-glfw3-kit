(defpackage #:cl-glfw3-kit
  (:use #:cl)
  (:export
   ;; this package's own version (see cl-glfw3-kit.asd's :version)
   #:library-version

   ;; conditions
   #:cl-glfw3-kit-error
   #:glfw-not-initialized
   #:glfw-not-initialized-description
   #:glfw-no-current-context
   #:glfw-no-current-context-description
   #:glfw-invalid-enum
   #:glfw-invalid-enum-description
   #:glfw-invalid-value
   #:glfw-invalid-value-description
   #:glfw-out-of-memory
   #:glfw-out-of-memory-description
   #:glfw-api-unavailable
   #:glfw-api-unavailable-description
   #:glfw-version-unavailable
   #:glfw-version-unavailable-description
   #:glfw-platform-error
   #:glfw-platform-error-description
   #:glfw-format-unavailable
   #:glfw-format-unavailable-description
   #:glfw-no-window-context
   #:glfw-no-window-context-description
   #:glfw-cursor-unavailable
   #:glfw-cursor-unavailable-description
   #:glfw-feature-unavailable
   #:glfw-feature-unavailable-description
   #:glfw-feature-unimplemented
   #:glfw-feature-unimplemented-description
   #:glfw-platform-unavailable
   #:glfw-platform-unavailable-description
   #:glfw-unknown-error
   #:glfw-unknown-error-code
   #:glfw-unknown-error-description

   ;; init/terminate/version, and the CPS session form
   #:call-with-glfw
   #:with-glfw
   #:glfw-version
   #:glfw-version-string
   #:*init-function*
   #:*terminate-function*

   ;; window: type, lifecycle, hints, properties
   #:glfw-window
   #:glfw-window-p
   #:default-window-hints
   #:call-with-glfw-window
   #:with-glfw-window
   #:window-should-close-p
   #:set-window-should-close
   #:window-size
   #:framebuffer-size
   #:window-title
   #:set-window-title
   #:*create-window-function*
   #:*destroy-window-function*

   ;; event callbacks, scoped to a window via the CPS session form
   #:call-with-glfw-callbacks
   #:with-glfw-callbacks

   ;; context and the CPS per-frame loop
   #:make-context-current
   #:swap-interval
   #:swap-buffers
   #:poll-events
   #:wait-events
   #:wait-events-timeout
   #:call-with-each-frame
   #:for-each-frame

   ;; input queries
   #:key-pressed-p
   #:mouse-button-pressed-p
   #:cursor-position

   ;; monitor
   #:glfw-monitor
   #:glfw-monitor-p
   #:primary-monitor
   #:list-monitors
   #:video-mode
   #:video-mode-width
   #:video-mode-height
   #:video-mode-red-bits
   #:video-mode-green-bits
   #:video-mode-blue-bits
   #:video-mode-refresh-rate))

(in-package #:cl-glfw3-kit)
