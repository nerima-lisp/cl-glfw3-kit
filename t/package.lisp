;;;; t/package.lisp
(defpackage #:cl-glfw3-kit/test
  (:use #:cl)
  (:shadowing-import-from #:cl-weave #:describe)
  (:import-from #:cl-weave
                #:it #:it-property #:it-each #:describe-each
                #:before-each #:after-each #:expect #:expect-not #:signals #:finishes
                #:gen-integer #:gen-keyword #:gen-member #:gen-such-that
                #:run-all)
  (:import-from #:cl-boundary-kit
                #:make-recording-boundary #:recording-boundary-invoke
                #:recording-boundary-calls #:assert-recorded-call-count)
  (:import-from #:cl-glfw3-kit
                ;; conditions
                #:cl-glfw3-kit-error
                #:glfw-not-initialized #:glfw-no-current-context #:glfw-invalid-enum
                #:glfw-invalid-value #:glfw-out-of-memory #:glfw-api-unavailable
                #:glfw-version-unavailable #:glfw-platform-error #:glfw-format-unavailable
                #:glfw-no-window-context #:glfw-cursor-unavailable #:glfw-feature-unavailable
                #:glfw-feature-unimplemented #:glfw-platform-unavailable
                #:glfw-unknown-error #:glfw-unknown-error-code
                ;; init/version
                #:library-version #:call-with-glfw #:with-glfw
                #:glfw-version #:glfw-version-string
                #:*init-function* #:*terminate-function*
                ;; window
                #:glfw-window #:glfw-window-p
                #:call-with-glfw-window #:with-glfw-window
                #:window-should-close-p #:set-window-should-close
                #:window-size #:framebuffer-size #:window-title #:set-window-title
                #:*create-window-function* #:*destroy-window-function*
                ;; callbacks
                #:call-with-glfw-callbacks #:with-glfw-callbacks
                ;; context
                #:make-context-current #:swap-interval #:swap-buffers
                #:poll-events #:wait-events #:wait-events-timeout
                #:call-with-each-frame #:for-each-frame
                ;; input
                #:key-pressed-p #:mouse-button-pressed-p #:cursor-position
                ;; monitor
                #:glfw-monitor #:glfw-monitor-p
                #:primary-monitor #:list-monitors #:video-mode
                #:video-mode-width #:video-mode-height #:video-mode-red-bits
                #:video-mode-green-bits #:video-mode-blue-bits #:video-mode-refresh-rate)
  ;; internal (unexported from CL-GLFW3-KIT) symbols the test suite reaches
  ;; into directly, to test pure logic below the FFI boundary without a
  ;; real GLFW call -- see CODING_STANDARD.md: exported vs. internal is
  ;; entirely a matter of the DEFPACKAGE :EXPORT list, so this is ordinary
  ;; package-qualified access, not a hack.
  (:import-from #:cl-glfw3-kit
                #:%encode-window-hint-value #:%encode-window-hints
                #:%key-keyword #:%mouse-button-keyword #:%action-keyword #:%decode-mods
                #:%key-code #:%mouse-button-code
                #:%check-glfw-error #:%signal-glfw-error #:*last-glfw-error*
                #:define-glfw-function #:%null-pointer
                #:*glfw-error-conditions* #:*glfw-boolean-window-hints*
                #:*glfw-integer-window-hints* #:*glfw-enum-window-hints*
                #:*glfw-client-api-values* #:*glfw-opengl-profile-values*
                #:*glfw-keys* #:*glfw-mouse-buttons* #:*glfw-actions* #:*glfw-mod-keys*)
  (:export #:run-tests))

(in-package #:cl-glfw3-kit/test)

(defun run-tests (&key (reporter :spec))
  "Plain (uninstrumented) test run -- drives checks.default/apps.test via
run-tests.lisp. See run-coverage.lisp for the coverage-gated variant: sb-cover
instrumentation needs its own forced recompile before the suite runs, which
this entry point (shared with an ordinary developer test-run) deliberately
does not pay for."
  (unless (run-all :reporter reporter :timeout-ms 20000)
    (error "cl-glfw3-kit test suite failed"))
  (format t "~&cl-glfw3-kit/test: successful completion with 0 failures~%")
  t)
